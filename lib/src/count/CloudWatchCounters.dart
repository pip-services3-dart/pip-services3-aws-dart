import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:aws_cloudwatch_api/monitoring-2010-08-01.dart';

import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../connect/AwsConnectionParams.dart';
import '../connect/AwsConnectionResolver.dart';

/// Performance counters that periodically dumps counters to AWS Cloud Watch Metrics.
///
/// ### Configuration parameters ###
///
/// - [connections]:
///     - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///     - [region]:                (optional) AWS region
/// - [credentials]:
///     - [store_key]:             (optional) a key to retrieve the credentials from [ICredentialStore](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICredentialStore-class.html)
///     - [access_id]:             AWS access/client id
///     - [access_key]:            AWS access/client id
/// - [options]:
///     - [interval]:              interval in milliseconds to save current counters measurements (default: 5 mins)
///     - [reset_timeout]:         timeout in milliseconds to reset the counters. 0 disables the reset (default: 0)
///
/// ### References ###
///
/// - *:context-info:\*:\*:1.0      (optional) [ContextInfo](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ContextInfo-class.html) to detect the context id and specify counters source
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connections
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [Counter](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/Counter-class.html) (in the Pip.Services components package)
/// See [CachedCounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/CachedCounters-class.html) (in the Pip.Services components package)
/// See [CompositeLogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/CompositeLogger-class.html) (in the Pip.Services components package)
///
/// ### Example ###
///
///     var counters = new CloudWatchCounters();
///     counters.config(ConfigParams.fromTuples([
///         'connection.region', 'us-east-1',
///         'connection.access_id', 'XXXXXXXXXXX',
///         'connection.access_key', 'XXXXXXXXXXX'
///     ]));
///     counters.setReferences(References.fromTuples([
///         Descriptor('pip-services', 'logger', 'console', 'default', '1.0'),
///         ConsoleLogger()
///     ]));
///
///     await counters.open('123');
///         ...
///
///     counters.increment('mycomponent.mymethod.calls');
///     var timing = counters.beginTiming('mycomponent.mymethod.exec_time');
///     try {
///         ...
///     } finally {
///         timing.endTiming();
///     }
///
///     counters.dump();

class CloudWatchCounters extends CachedCounters
    implements IReferenceable, IOpenable {
  final _logger = CompositeLogger();

  final _connectionResolver = AwsConnectionResolver();
  AwsConnectionParams _connection;
  int _connectTimeout = 30000;
  CloudWatch _service; //AmazonCloudWatchClient
  http.Client _client;

  String _source;
  String _instance;
  bool _opened = false;

  /// Creates a new instance of this counters.
  CloudWatchCounters() : super();

  /// Configures component by passing configuration parameters.
  ///
  ///  -  [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    _connectionResolver.configure(config);

    _source = config.getAsStringWithDefault('source', _source);
    _instance = config.getAsStringWithDefault('instance', _instance);
    _connectTimeout = config.getAsIntegerWithDefault(
        'options.connect_timeout', _connectTimeout);
  }

  /// Sets references to dependent components.
  ///
  ///  -  references 	references to locate the component dependencies.
  /// See [IReferences](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/IReferences-class.html) (in the Pip.Services commons package)
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    _connectionResolver.setReferences(references);

    var contextInfo = references.getOneOptional<ContextInfo>(
        Descriptor('pip-services', 'context-info', 'default', '*', '1.0'));
    if (contextInfo != null && _source == null) {
      _source = contextInfo.name;
    }
    if (contextInfo != null && _instance == null) {
      _instance = contextInfo.contextId;
    }
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return _opened;
  }

  /// Opens the component.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return  			Future that receives error or null no errors occured.
  @override
  Future open(String correlationId) async {
    if (_opened) {
      return;
    }
    _opened = true;
    _connection = await _connectionResolver.resolve(correlationId);
    //_connectTimeout
    final credentials = AwsClientCredentials(
        accessKey: _connection.getAccessId(),
        secretKey: _connection.getAccessKey());
    _client = http.Client();
    _service = CloudWatch(
        region: _connection.getRegion(),
        credentials: credentials,
        client: _client);
  }

  /// Closes component and frees used resources.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return  			Future that receives error or null no errors occured.
  @override
  Future close(String correlationId) async {
    if (_client != null) {
      _client.close();
    }
    _opened = false;
    _service = null;
  }

  MetricDatum _getCounterData(
      Counter counter, DateTime now, List<Dimension> dimensions) {
    MetricDatum value;

    switch (counter.type) {
      case CounterType.Increment:
        MetricDatum(
            metricName: counter.name,
            timestamp: counter.time,
            dimensions: dimensions,
            unit: StandardUnit.count,
            value: counter.count.toDouble());
        break;
      case CounterType.Interval:
        var stat = StatisticSet(
            maximum: counter.max.toDouble(),
            minimum: counter.min.toDouble(),
            sum: counter.count.toDouble(),
            sampleCount: counter.count.toDouble());
        MetricDatum(
            metricName: counter.name,
            timestamp: counter.time,
            dimensions: dimensions,
            unit: StandardUnit.milliseconds,
            statisticValues: stat);
        break;
      case CounterType.Statistics:
        var stat = StatisticSet(
            maximum: counter.max.toDouble(),
            minimum: counter.min.toDouble(),
            sum: counter.count.toDouble(),
            sampleCount: counter.count.toDouble());
        MetricDatum(
            metricName: counter.name,
            timestamp: counter.time,
            dimensions: dimensions,
            unit: StandardUnit.none,
            statisticValues: stat,
            value: counter.average);
        break;
      case CounterType.LastValue:
        MetricDatum(
            metricName: counter.name,
            timestamp: counter.time,
            dimensions: dimensions,
            unit: StandardUnit.none,
            value: counter.last.toDouble());
        break;
      case CounterType.Timestamp:
        MetricDatum(
            metricName: counter.name,
            timestamp: counter.time,
            dimensions: dimensions,
            unit: StandardUnit.none,
            value: counter.time.millisecondsSinceEpoch.toDouble());
        break;
    }

    return value;
  }

  /// Saves the current counters measurements.
  ///
  ///  -  [counters]      current counters measurements to be saves.
  @override
  Future save(List<Counter> counters) async {
    if (_service == null) return;

    var dimensions = <Dimension>[];
    dimensions.add(Dimension(name: 'InstanceID', value: _instance));

    var now = DateTime.now();
    var data = <MetricDatum>[];

    for (var counter in counters) {
      data.add(_getCounterData(counter, now, dimensions));

      if (data.length >= 20) {
        try {
          await _service.putMetricData(metricData: data, namespace: _source);
        } catch (ex) {
          if (_logger != null) {
            _logger.error('cloudwatch_counters', ex, 'putMetricData error');
          }
        }
        data = <MetricDatum>[];
      }
    }

    if (data.isNotEmpty) {
      try {
        await _service.putMetricData(metricData: data, namespace: _source);
      } catch (err) {
        if (_logger != null) {
          _logger.error('cloudwatch_counters', err, 'putMetricData error');
        }
      }
    }
  }
}
