import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart' as aws;
import 'package:aws_lambda_dart_runtime/runtime/context.dart' as awsctx;

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Abstract AWS Lambda function, that acts as a container to instantiate and run components
/// and expose them via external entry point.
///
/// When handling calls 'cmd' parameter determines which what action shall be called, while
/// other parameters are passed to the action itself.
///
/// Container configuration for this Lambda function is stored in <code>'./config/config.yml' file.
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
/// - *:logger:\*:\*:1.0            (optional) [ILogger]] components to pass log messages
/// - *:counters:\*:\*:1.0          (optional) [ICounters]] components to pass collected measurements
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery]] services to resolve connection
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [LambdaClient]
///
/// ### Example ###
///
///     class MyLambdaFunction extends LambdaFunction {
///         IMyController _controller ;
///         ...
///         MyLambdaFunction()
///             base('mygroup', 'MyGroup lambda function'){
///             dependencyResolver.put(
///                 'controller',
///                 Descriptor('mygroup','controller','*','*','1.0')
///             );
///         }
///
///         void setReferences(IReferences references) {
///             base.setReferences(references);
///             _controller = dependencyResolver.getRequired<IMyController>('controller');
///         }
///
///         void register() {
///             registerAction('get_mydata', null, (params, callback) => {
///                 var correlationId = params.correlation_id;
///                 var id = params.id;
///                 _controller.getMyData(correlationId, id, callback);
///             });
///             ...
///         }
///     }
///
///     var lambda = MyLambdaFunction();
///
///     await service.run();
///     print('MyLambdaFunction is started');

abstract class LambdaFunction extends Container {
  /// The performanc counters.
  final counters = CompositeCounters();

  /// The dependency resolver.
  final dependencyResolver = DependencyResolver();

  /// The map of registred validation schemas.
  Map<String, Schema> schemas = {};

  /// The map of registered actions.
  Map<String, Future Function(dynamic)> actions = {};

  /// The default path to config file.
  String configPath = './config/config.yml';

  /// Creates a new instance of this lambda function.
  ///
  ///  -  [name]          (optional) a container name (accessible via ContextInfo)
  ///  -  [description]   (optional) a container description (accessible via ContextInfo)
  LambdaFunction([String name, String description]) : super(name, description) {
    logger = ConsoleLogger();
  }

  String _getConfigPath() {
    return Platform.environment['CONFIG_PATH'] ?? configPath;
  }

  ConfigParams _getParameters() {
    var parameters = ConfigParams.fromValue(Platform.environment);
    return parameters;
  }

  void _captureExit(String correlationId) {
    logger.info(correlationId, 'Press Control-C to stop the microservice...');

    // Activate graceful exit
    ProcessSignal.sigint.watch().listen((signal) {
      if (Platform.operatingSystem.toLowerCase().contains('windows')) {
        close(correlationId);
        logger.info(correlationId, 'Goodbye!');
      }
      exit(0);
    });

    //Gracefully shutdown
    if (!Platform.operatingSystem.toLowerCase().contains('windows')) {
      ProcessSignal.sigquit.watch().listen((signal) {
        close(correlationId);
        logger.info(correlationId, 'Goodbye!');
        exit(0);
      });
    }
  }

  /// Sets references to dependent components.
  ///
  ///  -  [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    counters.setReferences(references);
    dependencyResolver.setReferences(references);
    register();
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

  /// Runs this lambda function, loads container configuration,
  /// instantiate components and manage their lifecycle,
  /// makes this function ready to access action calls.
  ///
  ///  Return  Future that receives null for success.
  /// Throws error
  Future run() async {
    var correlationId = info.name;

    try {
      var path = _getConfigPath();
      var parameters = _getParameters();
      readConfigFromFile(correlationId, path, parameters);
      _captureExit(correlationId);
      await open(correlationId);
    } catch (ex) {
      logger.fatal(
        correlationId,
        ex,
        'Process is terminated',
      );
      exit(1);
    }
  }

  /// Registers all actions in this lambda function.
  ///
  /// This method is called by the service and must be overriden
  /// in child classes.

  void register();

  /// Registers an action in this lambda function.
  ///
  ///  -  [cmd]           a action/command name.
  ///  -  [schema]        a validation schema to validate received parameters.
  ///  -  [action]        an action function that is called when action is invoked.
  void registerAction(
      String cmd, Schema schema, Future Function(dynamic) action) {
    if (cmd == null || cmd.isEmpty) {
      throw UnknownException(null, 'NO_COMMAND', 'Missing command');
    }

    if (action == null) {
      throw UnknownException(null, 'NO_ACTION', 'Missing action');
    }

    // Hack!!! Wrapping action to preserve prototyping context
    Future actionCurl(dynamic params) async {
      // Perform validation
      if (schema != null) {
        var correlationId = params['correlaton_id'];
        var err =
            schema.validateAndReturnException(correlationId, params, false);
        if (err != null) {
          throw err;
        }
      }

      // Todo: perform verification?
      return action(params);
    }

    actions[cmd] = actionCurl;
  }

  dynamic _execute(event, awsctx.Context context) async {
    String cmd = event['cmd'];
    var correlationId = event['correlation_id'];

    if (cmd == null) {
      throw BadRequestException(
          correlationId, 'NO_COMMAND', 'Cmd parameter is missing');
    }

    var action = actions[cmd];
    if (action == null) {
      throw BadRequestException(
              correlationId, 'NO_ACTION', 'Action ' + cmd + ' was not found')
          .withDetails('command', cmd);
    }

    return await action(event);
  }

  Future<aws.InvocationResult> _handler(
      awsctx.Context context, aws.AwsApiGatewayEvent event) async {
    var result;
    // If already started then execute
    if (isOpen()) {
      result = await _execute(json.decode(event.body), context);
    }
    // Start before execute
    else {
      try {
        await run();
        result = await _execute(json.decode(event.body), context);
      } catch (err) {
        result = ApplicationException().wrap(err);
      }
    }
    Map<String, dynamic> jsonMap;
    if (result != null) {
      jsonMap = result.toJson();
    }
    return aws.InvocationResult(context.requestId, aws.AwsApiGatewayResponse.fromJson(jsonMap));
  }

  /// Gets entry point into this lambda function.
  ///
  ///  -  [event]     an incoming event object with invocation parameters.
  ///  -  [context]   a context object with local references.
  aws.Handler<aws.AwsApiGatewayEvent> getHandler() {
    // Return plugin function
    return (awsctx.Context context, aws.AwsApiGatewayEvent event) {
      // Calling run with changed context
      return _handler(context, event);
    };
  }

  /// Calls registered action in this lambda function.
  /// 'cmd' parameter in the action parameters determin
  /// what action shall be called.
  ///
  /// This method shall only be used in testing.
  ///
  ///  -  [params] action parameters.
  ///  -  Return  Future that receives action result
  /// Throws error.
  Future act(params) async {
    var context =
        awsctx.Context(requestId: IdGenerator.nextLong(), handler: '');
    var event = aws.AwsApiGatewayEvent(body: json.encode(params));

    var result = await getHandler()(context, event);
    return result.body.body;
  }
}
