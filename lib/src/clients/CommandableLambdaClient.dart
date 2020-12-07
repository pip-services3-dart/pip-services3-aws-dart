import 'dart:async';

import './LambdaClient.dart';

/// Abstract client that calls commandable AWS Lambda Functions.
///
/// Commandable services are generated automatically for [ICommandable](https://pub.dev/documentation/pip_services3_commons/latest/pip_services3_commons/ICommandable-class.html).
/// Each command is exposed as action determined by "cmd" parameter.
///
/// ### Configuration parameters ###
///
/// - [connections]:
///     - [discovery_key]:               (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///     - [region]:                      (optional) AWS region
/// - [credentials]:
///     - [store_key]:                   (optional) a key to retrieve the credentials from [ICredentialStore](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICredentialStore-class.html)
///     - [access_id]:                   AWS access/client id
///     - [access_key]:                  AWS access/client id
/// - [options]:
///     - [connect_timeout]:             (optional) connection timeout in milliseconds (default: 10 sec)
///
/// ### References ###
///
/// - *:logger:\*:\*:1.0            (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - *:counters:\*:\*:1.0          (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [LambdaFunction]
///
/// ### Example ###
///
///     class MyLambdaClient extends CommandableLambdaClient implements IMyClient {
///         ...
///
///         public getData(String correlationId, id: string,
///             callback: (err: any, result: MyData) => void): void {
///
///             this.callCommand(
///                 "get_data",
///                 correlationId,
///                 { id: id },
///                 (err, result) => {
///                     callback(err, result);
///                 }
///             );
///         }
///         ...
///     }
///
///     var client = new MyLambdaClient();
///     client.configure(ConfigParams.fromTuples(
///         "connection.region", "us-east-1",
///         "connection.access_id", "XXXXXXXXXXX",
///         "connection.access_key", "XXXXXXXXXXX",
///         "connection.arn", "YYYYYYYYYYYYY"
///     ));
///
///     client.getData("123", "1", (err, result) => {
///         ...
///     });

class CommandableLambdaClient extends LambdaClient {
  String _name;

  /// Creates a new instance of this client.
  ///
  ///  -  name a service name.

  CommandableLambdaClient(String name) : super() {
    _name = name;
  }

  /// Calls a remote action in AWS Lambda function.
  /// The name of the action is added as "cmd" parameter
  /// to the action parameters.
  ///
  ///  -  [cmd]               an action name
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [params]            command parameters.
  ///  Return          Future that receives result
  /// Throws  error.

  Future callCommand(String cmd, String correlationId, params) async {
    var timing = instrument(correlationId, _name + '.' + cmd);
    var result;
    try {
      result = await call(cmd, correlationId, params);
    } catch (err) {
      rethrow;
    } finally {
      timing.endTiming();
    }
    return result;
  }
}
