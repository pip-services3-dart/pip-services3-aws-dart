import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../log/CloudWatchLogger.dart';
import '../count/CloudWatchCounters.dart';

/// Creates AWS components by their descriptors.
///
/// See [CloudWatchLogger]
/// See [CloudWatchCounters]
class DefaultAwsFactory extends Factory {
  static final descriptor =
      Descriptor('pip-services', 'factory', 'aws', 'default', '1.0');

  static final CloudWatchLoggerDescriptor =
      Descriptor('pip-services', 'logger', 'cloudwatch', '*', '1.0');
  static final CloudWatchCountersDescriptor =
      Descriptor('pip-services', 'counters', 'cloudwatch', '*', '1.0');

  /// Create ainstance of the factory.
  DefaultAwsFactory() : super() {
    registerAsType(
        DefaultAwsFactory.CloudWatchLoggerDescriptor, CloudWatchLogger);
    registerAsType(
        DefaultAwsFactory.CloudWatchCountersDescriptor, CloudWatchCounters);
  }
}
