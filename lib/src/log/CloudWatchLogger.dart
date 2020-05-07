import 'dart:async';

import 'package:aws_logs_api/logs-2014-03-28.dart';

import 'package:http/http.dart' as http;

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import '../connect/AwsConnectionParams.dart';
import '../connect/AwsConnectionResolver.dart';

/// Logger that writes log messages to AWS Cloud Watch Log.
///
/// ### Configuration parameters ###
///
/// - [stream]:                        (optional) Cloud Watch Log stream (default: context name)
/// - [group]:                         (optional) Cloud Watch Log group (default: context instance ID or hostname)
/// - [connections]:
///     - [discovery_key]:               (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/package:pip_services3_components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
///     - [region]:                      (optional) AWS region
/// - [credentials]:
///     - [store_key]:                   (optional) a key to retrieve the credentials from [[https://rawgit.com/pip-services-node/package:pip_services3_components-node/master/doc/api/interfaces/auth.icredentialstore.html ICredentialStore]]
///     - [access_id]:                   AWS access/client id
///     - [access_key]:                  AWS access/client id
/// - [options]:
///     - [interval]:        interval in milliseconds to save current counters measurements (default: 5 mins)
///     - [reset_timeout]:   timeout in milliseconds to reset the counters. 0 disables the reset (default: 0)
///
/// ### References ###
///
/// - *:context-info:\*:\*:1.0      (optional) [ContextInfo] to detect the context id and specify counters source
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery] services to resolve connections
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [Counter] (in the Pip.Services components package)
/// See [CachedCounters] (in the Pip.Services components package)
/// See [CompositeLogger] (in the Pip.Services components package)

///
/// ### Example ###
///
///     var logger =  Logger();
///     logger.config(ConfigParams.fromTuples(
///         'stream', 'mystream',
///         'group', 'mygroup',
///         'connection.region', 'us-east-1',
///         'connection.access_id', 'XXXXXXXXXXX',
///         'connection.access_key', 'XXXXXXXXXXX'
///     ));
///     logger.setReferences(References.fromTuples([
///          Descriptor('pip-services', 'logger', 'console', 'default', '1.0'),
///          ConsoleLogger()
///     ]));
///
///     logger.open('123');
///         ...
///
///     logger.setLevel(LogLevel.debug);
///
///     logger.error('123', ex, 'Error occured: %s', ex.message);
///     logger.debug('123', 'Everything is OK.');

class CloudWatchLogger extends CachedLogger
    implements IReferenceable, IOpenable {
  Timer _timer;

  final _connectionResolver = AwsConnectionResolver();
  CloudWatchLogs _service; //AmazonCloudWatchLogsClient
  http.Client _client;
  AwsConnectionParams _connection;
  int _connectTimeout = 30000;

  String _group = 'undefined';
  String _stream;
  String _lastToken;

  final _logger = CompositeLogger();

  /// Creates a new instance of this logger.
  CloudWatchLogger() : super();

  /// Configures component by passing configuration parameters.
  ///
  ///  -  [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    _connectionResolver.configure(config);

    _group = config.getAsStringWithDefault('group', _group);
    _stream = config.getAsStringWithDefault('stream', _stream);
    _connectTimeout = config.getAsIntegerWithDefault(
        'options.connect_timeout', _connectTimeout);
  }

  /// Sets references to dependent components.
  ///
  ///  -  [references] 	references to locate the component dependencies.
  /// See [IReferences] (in the Pip.Services commons package)
  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    _logger.setReferences(references);
    _connectionResolver.setReferences(references);

    var contextInfo = references.getOneOptional<ContextInfo>(
        Descriptor('pip-services', 'context-info', 'default', '*', '1.0'));
    if (contextInfo != null && this._stream == null) {
      _stream = contextInfo.name;
    }
    if (contextInfo != null && this._group == null) {
      _group = contextInfo.contextId;
    }
  }

  /// Writes a log message to the logger destination.
  ///
  ///  -  [level]             a log level.
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [error]             an error object associated with this message.
  ///  -  [message]           a human-readable message to log.
  @override
  void write(
      LogLevel level, String correlationId, Exception ex, String message) {
    if (getLevel().index < level.index) {
      return;
    }
    super.write(level, correlationId, ex, message);
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return _timer != null;
  }

  /// Opens the component.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives  null no errors occured.
  /// Throws error
  @override
  Future open(String correlationId) async {
    if (isOpen()) {
      return;
    }

    _connection = await _connectionResolver.resolve(correlationId);

    //timeout: this._connectTimeout

    _client = http.Client();
    final credentials = AwsClientCredentials(
        accessKey: _connection.getAccessId(),
        secretKey: _connection.getAccessKey());
    _service = CloudWatchLogs(
        region: _connection.getRegion(),
        credentials: credentials,
        client: _client);

    try {
      await _service.createLogGroup(logGroupName: _group);
    } catch (err) {
      if (!(err is ResourceAlreadyExistsException)) {
        rethrow;
      }
    }

    try {
      await _service.createLogStream(
          logGroupName: _group, logStreamName: _stream);
      _lastToken = null;
    } catch (err) {
      if (err is ResourceAlreadyExistsException) {
        var data = await _service.describeLogStreams(
            logGroupName: _group, logStreamNamePrefix: _stream);
        if (data.logStreams.isNotEmpty) {
          _lastToken = data.logStreams[0].uploadSequenceToken;
        }
      } else {
        rethrow;
      }
    }

    _timer ??= Timer.periodic(Duration(milliseconds: interval), (tm) {
      dump();
    });
  }

  /// Closes component and frees used resources.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives error or null no errors occured.
  @override
  Future close(String correlationId) async {
    await save(cache);

    if (_timer != null) {
      _timer.cancel();
    }

    cache = [];
    _timer = null;
    _service = null;
  }

  String _formatMessageText(LogMessage message) {
    var result = '';
    result += '[' +
        (message.source ?? '---') +
        ':' +
        (message.correlation_id ?? '---') +
        ':' +
        message.level +
        '] ' +
        message.message;
    if (message.error != null) {
      if (message.message == null || message.message.isEmpty) {
        result += 'Error: ';
      } else {
        result += ': ';
      }

      result += message.error.message;

      if (message.error.stack_trace != null &&
          message.error.stack_trace.isNotEmpty) {
        result += ' StackTrace: ' + message.error.stack_trace;
      }
    }

    return result;
  }

  /// Saves log messages from the cache.
  ///
  ///  -  [messages]  a list with log messages
  ///  Return  Future that receives error or null for success.
  @override
  Future save(List<LogMessage> messages) async {
    if (!isOpen() || messages == null || messages.isEmpty) {
      return;
    }

    if (_service == null) {
      throw ConfigException(
          'cloudwatch_logger', 'NOT_OPENED', 'CloudWatchLogger is not opened');
    }

    var events = <InputLogEvent>[];

    for (var message in messages) {
      var event = InputLogEvent(
          message: message.message,
          timestamp: message.time.millisecondsSinceEpoch);
      events.add(event);
    }

    // get token again if saving log from another container

    var data = await _service.describeLogStreams(
        logGroupName: _group, logStreamNamePrefix: _stream);

    if (data.logStreams.isNotEmpty) {
      _lastToken = data.logStreams[0].uploadSequenceToken;
    }

    try {
      var data = await _service.putLogEvents(
          logEvents: events,
          logGroupName: _group,
          logStreamName: _stream,
          sequenceToken: _lastToken);
      _lastToken = data.nextSequenceToken;
    } catch (err) {
      if (_logger != null) {
        _logger.error('cloudwatch_logger', err, 'putLogEvents error');
      }
    }
  }
}
