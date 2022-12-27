# <img src="https://uploads-ssl.webflow.com/5ea5d3315186cf5ec60c3ee4/5edf1c94ce4c859f2b188094_logo.svg" alt="Pip.Services Logo" width="200"> <br/> AWS specific components for Dart

This module is a part of the [Pip.Services](http://pipservices.org) polyglot microservices toolkit.

This module contains components for supporting work with the AWS cloud platform.

The module contains the following packages:
- **Build** - factories for constructing module components
- **Clients** - client components for working with Lambda AWS
- **Connect** - components of installation and connection settings
- **Container** - components for creating containers for Lambda server-side AWS functions
- **Count** - components of working with counters (metrics) with saving data in the CloudWatch AWS service
- **Log** - logging components with saving data in the CloudWatch AWS service


<a name="links"></a> Quick links:

* [Configuration](https://www.pipservices.org/recipies/configuration)
* [aws-lambda-dart-runtime](https://github.com/awslabs/aws-lambda-dart-runtime)
* [aws-client](https://github.com/agilord/aws_client)
* [API Reference](https://pub.dev/documentation/pip_services3_aws/latest/pip_services3_aws/pip_services3_aws-library.html)
* [Change Log](CHANGELOG.md)
* [Get Help](https://www.pipservices.org/community/help)
* [Contribute](https://www.pipservices.org/community/contribute)


# Warning!

The service is not finished at the moment. Development progress is as follows:
- The components of CloudWatchCounters and CloudWatchLogger are tested and working.
- The components for creating server-side functions for the Lambda service are tested and work, but are not assembled due to the use of dart: mirrors in dart2native. To build in OSs other than Linux, use the docker and the build_lambda.ps1 script.
- The components for creating a client for Lambda services are not fully tested. Requires full testing on AWS.


## Use

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  pip_services3_aws: version
```

Now you can install package from the command line:
```bash
pub get
```

## Develop

For development you shall install the following prerequisites:
* Dart SDK 2
* Visual Studio Code or another IDE of your choice
* Docker

Install dependencies:
```bash
pub get
```

Run automated tests:
```bash
pub run test
```

Generate API documentation:
```bash
./docgen.ps1
```

Before committing changes run dockerized build and test as:
```bash
./build.ps1
./test.ps1
./clear.ps1
```

## Contacts

The Dart version of Pip.Services is created and maintained by:
 - **Sergey Seroukhov**
 - **Levichev Dmitry**

 The documentation is written by:
- **Levichev Dmitry**
