import 'package:pip_services3_commons/pip_services3_commons.dart';

import './LambdaFunction.dart';

/// Abstract AWS Lambda function, that acts as a container to instantiate and run components
/// and expose them via external entry point. All actions are automatically generated for commands
/// defined in [ICommandable components]. Each command is exposed as an action defined by "cmd" parameter.
///
/// Container configuration for this Lambda function is stored in <code>"./config/config.yml" file.
/// But this path can be overriden by <code>CONFIG_PATH environment variable.
///
/// ### Configuration parameters ###
///
/// - [dependencies]:
///     - [controller]:                  override for Controller dependency
/// - [connections]:
///     - [discovery_key]:               (optional) a key to retrieve the connection from [IDiscovery]
///     - [region]:                      (optional) AWS region
/// - [credentials]:
///     - [store_key]:                   (optional) a key to retrieve the credentials from [ICredentialStore]
///     - [access_id]:                   AWS access/client id
///     - [access_key]:                  AWS access/client id
///
/// ### References ###
///
/// - *:logger:\*:\*:1.0            (optional) [ILogger] components to pass log messages
/// - *:counters:\*:\*:1.0          (optional) [ICounters] components to pass collected measurements
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery] services to resolve connection
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [[LambdaClient]]
///
/// ### Example ###
///
///     class MyLambdaFunction extends CommandableLambdaFunction {
///         private _controller: IMyController;
///         ...
///         public constructor() {
///             base("mygroup", "MyGroup lambda function");
///             this._dependencyResolver.put(
///                 "controller",
///                 new Descriptor("mygroup","controller","*","*","1.0")
///             );
///         }
///     }
///
///     var lambda = new MyLambdaFunction();
///
///     service.run((err) => {
///         console.log("MyLambdaFunction is started");
///     });

abstract class CommandableLambdaFunction extends LambdaFunction {
  /// Creates a new instance of this lambda function.
  ///
  ///  -  [name]          (optional) a container name (accessible via ContextInfo)
  ///  -  [description]   (optional) a container description (accessible via ContextInfo)
  CommandableLambdaFunction(String name, [String description])
      : super(name, description) {
    dependencyResolver.put('controller', 'none');
  }

  void _registerCommandSet(CommandSet commandSet) {
    var commands = commandSet.getCommands();
    for (var index = 0; index < commands.length; index++) {
      var command = commands[index];

      registerAction(command.getName(), null, (params) async {
        var correlationId = params.correlation_id;
        var args = Parameters.fromValue(params);
        var timing =
            instrument(correlationId, info.name + '.' + command.getName());
        var result;
        try {
          result = await command.execute(correlationId, args);
        } catch (ex) {
          rethrow;
        } finally {
          timing.endTiming();
        }
        return result;
      });
    }
  }

  /// Registers all actions in this lambda function.
  @override
  void register() {
    var controller =
        dependencyResolver.getOneRequired<ICommandable>('controller');
    var commandSet = controller.getCommandSet();
    _registerCommandSet(commandSet);
  }
}
