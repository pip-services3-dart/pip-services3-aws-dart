import 'dart:io';
import 'package:test/test.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_aws/pip_services3_aws.dart';
import './LoggerFixture.dart';

void main() {
  group('CloudWatchLogger', () {
    CloudWatchLogger _logger;
    LoggerFixture _fixture;

    var AWS_REGION = Platform.environment['AWS_REGION'];
    var AWS_ACCESS_ID = Platform.environment['AWS_ACCESS_ID'];
    var AWS_ACCESS_KEY = Platform.environment['AWS_ACCESS_KEY'];

    if (AWS_REGION == null || AWS_ACCESS_ID == null || AWS_ACCESS_KEY == null) {
      return;
    }

    setUp(() async {
      _logger = CloudWatchLogger();
      _fixture = LoggerFixture(_logger);

      var config = ConfigParams.fromTuples([
        'group',
        'TestGroup',
        'connection.region',
        AWS_REGION,
        'credential.access_id',
        AWS_ACCESS_ID,
        'credential.access_key',
        AWS_ACCESS_KEY
      ]);
      _logger.configure(config);

      var contextInfo = ContextInfo();
      contextInfo.name = 'TestStream';

      var references = References.fromTuples([
        Descriptor('pip-services', 'context-info', 'default', 'default', '1.0'),
        contextInfo,
        Descriptor('pip-services', 'counters', 'cloudwatch', 'default', '1.0'),
        _logger
      ]);
      _logger.setReferences(references);

      await _logger.open(null);
    });

    tearDown(() async {
      await _logger.close(null);
    });

    test('Log Level', () {
      _fixture.testLogLevel();
    });

    test('Simple Logging', () async {
      await _fixture.testSimpleLogging();
    });

    test('Error Logging', () async {
      await _fixture.testErrorLogging();
    });
  });
}
