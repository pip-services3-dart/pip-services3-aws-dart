import 'dart:async';
import 'dart:convert';

import 'package:http_client/console.dart';
import 'package:aws_client/aws_client.dart';
import 'package:aws_client/lambda.dart';
import 'package:aws_client/src/credentials.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import '../connect/AwsConnectionParams.dart';
import '../connect/AwsConnectionResolver.dart';

/// Abstract client that calls AWS Lambda Functions.
///
/// When making calls 'cmd' parameter determines which what action shall be called, while
/// other parameters are passed to the action itself.
///
/// ### Configuration parameters ###
///
/// - [connections]:
///     - [discovery_key]:               (optional) a key to retrieve the connection from [IDiscovery]
///     - [region]:                      (optional) AWS region
/// - [credentials]:
///     - [store_key]:                   (optional) a key to retrieve the credentials from [ICredentialStore]
///     - [access_id]:                   AWS access/client id
///     - [access_key]:                  AWS access/client id
/// - [options]:
///     - [connect_timeout]:             (optional) connection timeout in milliseconds (default: 10 sec)
///
/// ### References ###
///
/// - *:logger:\*:\*:1.0            (optional) [ILogger] components to pass log messages
/// - *:counters:\*:\*:1.0          (optional) [ICounters] components to pass collected measurements
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery] services to resolve connection
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [LambdaFunction]
/// See [CommandableLambdaClient]
///
/// ### Example ###
///
///     class MyLambdaClient extends LambdaClient implements IMyClient {
///         ...
///
///         public getData(String correlationId, id: string,
///             callback: (err: any, result: MyData) => void): void {
///
///             var timing = this.instrument(correlationId, 'myclient.get_data');
///             this.call('get_data' correlationId, { id: id }, (err, result) => {
///                 timing.endTiming();
///                 callback(err, result);
///             });
///         }
///         ...
///     }
///
///     var client = new MyLambdaClient();
///     client.configure(ConfigParams.fromTuples(
///         'connection.region', 'us-east-1',
///         'connection.access_id', 'XXXXXXXXXXX',
///         'connection.access_key', 'XXXXXXXXXXX',
///         'connection.arn', 'YYYYYYYYYYYYY'
///     ));
///
///     client.getData('123', '1', (err, result) => {
///         ...
///     });

abstract class LambdaClient
    implements IOpenable, IConfigurable, IReferenceable {
  /// The reference to AWS Lambda Function.
  Lambda lambda;

  Client _httpClient;
  Aws _aws;

  /// The opened flag.
  bool opened = false;

  /// The AWS connection parameters
  AwsConnectionParams connection;
  var _connectTimeout = 10000;

  /// The dependencies resolver.
  final dependencyResolver = DependencyResolver();

  /// The connection resolver.
  final connectionResolver = AwsConnectionResolver();

  /// The logger.
  final logger = CompositeLogger();

  /// The performance counters.
  final counters = CompositeCounters();

  /// Configures component by passing configuration parameters.
  ///
  ///  -  [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    connectionResolver.configure(config);
    dependencyResolver.configure(config);

    _connectTimeout = config.getAsIntegerWithDefault(
        'options.connect_timeout', _connectTimeout);
  }

  /// Sets references to dependent components.
  ///
  ///  -  [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    logger.setReferences(references);
    counters.setReferences(references);
    connectionResolver.setReferences(references);
    dependencyResolver.setReferences(references);
  }

  /// Adds instrumentation to log calls and measure call time.
  /// It returns a Timing object that is used to end the time measurement.
  ///
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [name]              a method name.
  /// Returns Timing object to end the time measurement.
  Timing instrument(String correlationId, String name) {
    logger.trace(correlationId, 'Executing %s method', [name]);
    return counters.beginTiming(name + '.exec_time');
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return opened;
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

    var err = await Future.wait([
      () async {
        connection = await connectionResolver.resolve(correlationId);
      }(),
      () async {
        //final Client httpClient = ConsoleClient(idleTimeout: Duration(milliseconds: _connectTimeout));
        _httpClient = ConsoleClient();
        final credentials = Credentials(
            accessKey: connection.getAccessId(),
            secretKey: connection.getAccessKey());
        //
        try {
          _aws = Aws(credentials: credentials, httpClient: _httpClient);
          lambda = _aws.lambda(connection.getRegion());

          opened = true;
          logger.debug(correlationId, 'Lambda client connected to %s',
              [connection.getArn()]);
        } catch (ex) {
          logger.error(correlationId, ex, 'Error while open AWS client');
          return ex;
        } finally {
          await _httpClient.close();
        }
      }()
    ]);

    if (err.isNotEmpty) {
      throw err[0];
    }
  }

  /// Closes component and frees used resources.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives error or null no errors occured.
  @override
  Future close(String correlationId) async {
    if (_httpClient != null) {
      await _httpClient.close();
    }
    opened = false;
  }

  /// Performs AWS Lambda Function invocation.
  ///
  ///  -  invocationType    an invocation type: 'RequestResponse' or 'Event'
  ///  -  cmd               an action name to be called.
  ///  -  correlationId 	(optional) transaction id to trace execution through call chain.
  ///  -  args              action arguments
  ///  Return          Future that receives action result
  /// Throws error.

  Future invoke(LambdaInvocationType invocationType, String cmd,
      String correlationId, Map args) async {
    if (cmd == null || cmd.isEmpty) {
      var err = UnknownException(
          correlationId, 'NO_COMMAND', 'Missing Seneca pattern cmd');
      logger.error(correlationId, err, 'Failed to call %s', [cmd]);
      throw err;
    }

    var cloneArgs = Map.from(args);
    cloneArgs['cmd'] = cmd;
    cloneArgs['correlation_id'] = correlationId ?? IdGenerator.nextShort();

    var headers = {'X-Amz-Log-Type': 'None'};

    try {
      var data = await lambda.invoke(connection.getArn(), cloneArgs.toString(),
          headers: headers, invocationType: invocationType);

      var result = await data.readAsString(); //readAsBytes();

      try {
        result = json.decode(result);
      } catch (err) {
        throw InvocationException(correlationId, 'DESERIALIZATION_FAILED',
                'Failed to deserialize result')
            .withCause(err);
      }

      return result;
    } catch (err) {
      logger.error(correlationId, err, 'Failed to invoke lambda function');

      throw InvocationException(
              correlationId, 'CALL_FAILED', 'Failed to invoke lambda function')
          .withCause(err);
    }
  }

  /// Calls a AWS Lambda Function action.
  ///
  ///  -  [cmd]               an action name to be called.
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [params]            (optional) action parameters.
  ///  Returns               Future that receives result object
  /// Throws error.

  Future call(String cmd, String correlationId, params) {
    return invoke(
        LambdaInvocationType.RequestResponse, cmd, correlationId, params);
  }

  /// Calls a AWS Lambda Function action asynchronously without waiting for response.
  ///
  ///  -  [cmd]               an action name to be called.
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [params]            (optional) action parameters.
  ///  Returns                Future that receives null for success.
  /// Throws error or

  Future callOneWay(String cmd, String correlationId, params) async {
    await invoke(LambdaInvocationType.Event, cmd, correlationId, params);
  }
}
