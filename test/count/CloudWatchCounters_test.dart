
import 'dart:io';
import 'package:test/test.dart';
import  'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_aws/pip_services3_aws.dart';
import './CountersFixture.dart';

void main(){
group('CloudWatchCounters', () {
    CloudWatchCounters _counters;
    CountersFixture _fixture;

    var AWS_REGION = Platform.environment['AWS_REGION'] ?? '';
    var AWS_ACCESS_ID = Platform.environment['AWS_ACCESS_ID'] ?? '';
    var AWS_ACCESS_KEY = Platform.environment['AWS_ACCESS_KEY'] ?? '';

    if (AWS_REGION == null || AWS_ACCESS_ID == null || AWS_ACCESS_KEY == null) {
      return;
    }

    setUp(()  async {

        _counters =  CloudWatchCounters();
        _fixture =  CountersFixture(_counters);

        var config = ConfigParams.fromTuples([
            'interval', '5000',
            'connection.region', AWS_REGION,
            'credential.access_id', AWS_ACCESS_ID,
            'credential.access_key', AWS_ACCESS_KEY
        ]);
        _counters.configure(config);

        var contextInfo = ContextInfo();
        contextInfo.name = 'Test';
        contextInfo.description = 'This is a test container';

        var references = References.fromTuples([
            Descriptor('pip-services', 'context-info', 'default', 'default', '1.0'), contextInfo,
            Descriptor('pip-services', 'counters', 'cloudwatch', 'default', '1.0'), _counters
        ]);
        _counters.setReferences(references);

        await _counters.open(null);
    });

    tearDown(()  async{
       await _counters.close(null);
    });

    test('Simple Counters', () async {
        await _fixture.testSimpleCounters();
    });

    test('Measure Elapsed Time', () async {
        await _fixture.testMeasureElapsedTime();
    });

});
}