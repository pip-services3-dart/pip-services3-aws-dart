# <img src="https://github.com/pip-services/pip-services/raw/master/design/Logo.png" alt="Pip.Services Logo" style="max-width:30%">
# AWS specific components for Dart

This framework is a part of [Pip.Services](https://github.com/pip-services/pip-services) project.
It contains components for AWS cloud platform:

- **clients** - LambdaClient and CommandableLambdaClient
- **container** - LambdaFunction and CommandableLambdaFunction
- **connect** - AwsConnectionParams and AwsConnectionResolver

Quick Links:

* [Downloads](https://github.com/pip-services3-dart/pip-services3-aws-dart/blob/master/doc/Downloads.md)
* [API Reference](https://pub.dev/documentation/pip_services3_aws/latest/pip_services3_aws/pip_services3_aws-library.html)
* [Building and Testing](https://github.com/pip-services3-dart/pip-services3-aws-dart/blob/master/doc/Development.md)
* [Contributing](https://github.com/pip-services3-dart/pip-services3-aws-dart/blob/master/docs/Development.md#contrib)


# Warning!

The service is not finished at the moment. Development progress is as follows:
- The components of CloudWatchCounters and CloudWatchLogger are tested and working.
- The components for creating server-side functions for the Lambda service are tested and work, but are not assembled due to the use of dart: mirrors in dart2native. To build in OSs other than Linux, use the docker and the build_lambda.ps1 script.
- The components for creating a client for Lambda services are not fully tested. Requires full testing on AWS.


## Help links

* (https://github.com/awslabs/aws-lambda-dart-runtime)
* (https://github.com/agilord/aws_client)


## Acknowledgements

The Dart version of Pip.Services is created and maintained by:
 - **Sergey Seroukhov**
 - **Levichev Dmitry**

 The documentation is written by:
- **Levichev Dmitry**
