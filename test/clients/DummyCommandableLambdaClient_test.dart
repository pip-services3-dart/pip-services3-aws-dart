
import 'dart:io';
import 'package:test/test.dart';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../DummyClientFixture.dart';
import  './DummyCommandableLambdaClient.dart';

void main(){
var awsAccessId = Platform.environment['AWS_ACCESS_ID'];
var awsAccessKey = Platform.environment['AWS_ACCESS_KEY'];
var lambdaArn = Platform.environment['LAMBDA_ARN'];

group('DummyCommandableLambdaClient', () {
    if (awsAccessId == null || awsAccessKey== null || lambdaArn == null) {
      return;
    }

    var lambdaConfig = ConfigParams.fromTuples([
        'connection.protocol', 'aws',
        'connection.arn', lambdaArn,
        'credential.access_id', awsAccessId,
        'credential.access_key', awsAccessKey,
        'options.connection_timeout', 30000
    ]);

    DummyCommandableLambdaClient client ;
    DummyClientFixture fixture;

    setUp(() async  {
        client = DummyCommandableLambdaClient();
        client.configure(lambdaConfig);

        fixture = DummyClientFixture(client);

        await client.open(null);
    });

    tearDown(() async {
        await client.close(null);
    });

    test('Crud Operations', () async {
       await  fixture.testCrudOperations();
    });

});
}