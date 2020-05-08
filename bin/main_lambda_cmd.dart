import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';

import '../test/container/DummyCommandableLambdaFunction.dart';

void main() async {
  var lambda = DummyCommandableLambdaFunction();

  /// The Runtime is a singleton. You can define the handlers as you wish.
  Runtime()
    ..registerHandler<AwsApiGatewayEvent>('dummy', lambda.getHandler())
    ..invoke();
}
