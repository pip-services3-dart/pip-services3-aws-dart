import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_aws/pip_services3_aws.dart';
import '../DummyFactory.dart';

class DummyCommandableLambdaFunction extends CommandableLambdaFunction {
  DummyCommandableLambdaFunction() : super('dummy', 'Dummy lambda function') {
    dependencyResolver.put(
        'controller',
         Descriptor(
            'pip-services-dummies', 'controller', 'default', '*', '*'));
    factories.add( DummyFactory());
  }
}

//export const handler = new DummyCommandableLambdaFunction().getHandler();
