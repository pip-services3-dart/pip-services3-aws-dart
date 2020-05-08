import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Contains connection parameters to authenticate against Amazon Web Services (AWS)
/// and connect to specific AWS resource.
///
/// The class is able to compose and parse AWS resource ARNs.
///
/// ### Configuration parameters ###
///
/// - [access_id]:     application access id
/// - [client_id]:     alternative to access_id
/// - [access_key]:    application secret key
/// - [client_key]:    alternative to access_key
/// - [secret_key]:    alternative to access_key
///
/// In addition to standard parameters [CredentialParams] may contain any number of custom parameters
///
/// See [AwsConnectionResolver]
///
/// ### Example ###
///
///     var connection = AwsConnectionParams.fromTuples(
///         'region', 'us-east-1',
///         'access_id', 'XXXXXXXXXXXXXXX',
///         'secret_key', 'XXXXXXXXXXXXXXX',
///         'service', 's3',
///         'bucket', 'mybucket'
///     );
///
///     var region = connection.getRegion();                     // Result: 'us-east-1'
///     var accessId = connection.getAccessId();                 // Result: 'XXXXXXXXXXXXXXX'
///     var secretKey = connection.getAccessKey();               // Result: 'XXXXXXXXXXXXXXX'
///     var pin = connection.getAsNullableString('bucket');      // Result: 'mybucket'

class AwsConnectionParams extends ConfigParams {
  /// Creates an new instance of the connection parameters.
  ///
  ///  -  [values] 	(optional) an object to be converted into key-value pairs to initialize this connection.

  AwsConnectionParams([values]) : super(values);

  /// Gets the AWS partition name.
  ///
  /// Returns the AWS partition name.
  String getPartition() {
    return super.getAsNullableString('partition') ?? 'aws';
  }

  /// Sets the AWS partition name.
  ///
  ///  -  value a new AWS partition name.
  void setPartition(String value) {
    super.put('partition', value);
  }

  /// Gets the AWS service name.
  ///
  /// Returns the AWS service name.
  String getService() {
    return super.getAsNullableString('service') ??
        super.getAsNullableString('protocol');
  }

  /// Sets the AWS service name.
  ///
  ///  -  [value] a new AWS service name.
  void setService(String value) {
    super.put('service', value);
  }

  /// Gets the AWS region.
  ///
  /// Returns the AWS region.
  String getRegion() {
    return super.getAsNullableString('region');
  }

  /// Sets the AWS region.
  ///
  ///  -  [value] a new AWS region.
  void setRegion(String value) {
    super.put('region', value);
  }

  /// Gets the AWS account id.
  ///
  /// Returns the AWS account id.
  String getAccount() {
    return super.getAsNullableString('account');
  }

  /// Sets the AWS account id.
  ///
  ///  -  [value] the AWS account id.
  void setAccount(String value) {
    super.put('account', value);
  }

  /// Gets the AWS resource type.
  ///
  /// Returns the AWS resource type.
  String getResourceType() {
    return super.getAsNullableString('resource_type');
  }

  /// Sets the AWS resource type.
  ///
  ///  -  [value] a new AWS resource type.
  void setResourceType(String value) {
    super.put('resource_type', value);
  }

  /// Gets the AWS resource id.
  ///
  /// Returns the AWS resource id.
  String getResource() {
    return super.getAsNullableString('resource');
  }

  /// Sets the AWS resource id.
  ///
  ///  -  [value] a new AWS resource id.
  void setResource(String value) {
    super.put('resource', value);
  }

  /// Gets the AWS resource ARN.
  /// If the ARN is not defined it automatically generates it from other properties.
  ///
  /// Returns the AWS resource ARN.
  String getArn() {
    var arn = super.getAsNullableString('arn');
    if (arn != null && arn.isNotEmpty) return arn;

    arn = 'arn';
    var partition = getPartition() ?? 'aws';
    arn += ':' + partition;
    var service = getService() ?? '';
    arn += ':' + service;
    var region = getRegion() ?? '';
    arn += ':' + region;
    var account = getAccount() ?? '';
    arn += ':' + account;
    var resourceType = getResourceType() ?? '';
    if (resourceType != '') arn += ':' + resourceType;
    var resource = getResource() ?? '';
    arn += ':' + resource;

    return arn;
  }

  /// Sets the AWS resource ARN.
  /// When it sets the value, it automatically parses the ARN
  /// and sets individual parameters.
  ///
  ///  -  [value] a new AWS resource ARN.
  void setArn(String value) {
    super.put('arn', value);

    if (value != null && value.isNotEmpty) {
      var tokens = value.split(':');
      setPartition(tokens[1]);
      setService(tokens[2]);
      setRegion(tokens[3]);
      setAccount(tokens[4]);
      if (tokens.length > 6) {
        setResourceType(tokens[5]);
        setResource(tokens[6]);
      } else {
        var temp = tokens[5];
        var pos = temp.indexOf('/');
        if (pos > 0) {
          setResourceType(temp.substring(0, pos));
          setResource(temp.substring(pos + 1));
        } else {
          setResourceType(null);
          setResource(temp);
        }
      }
    }
  }

  /// Gets the AWS access id.
  ///
  /// Returns the AWS access id.
  String getAccessId() {
    return super.getAsNullableString('access_id') ??
        super.getAsNullableString('client_id');
  }

  /// Sets the AWS access id.
  ///
  ///  -  [value] the AWS access id.
  void setAccessId(String value) {
    super.put('access_id', value);
  }

  /// Gets the AWS client key.
  ///
  /// Returns the AWS client key.
  String getAccessKey() {
    return super.getAsNullableString('access_key') ??
        super.getAsNullableString('client_key');
  }

  /// Sets the AWS client key.
  ///
  ///  -  [value] a new AWS client key.
  void setAccessKey(String value) {
    super.put('access_key', value);
  }

  /// Creates a new AwsConnectionParams object filled with key-value pairs serialized as a string.
  ///
  ///  -  [line] 		a string with serialized key-value pairs as 'key1=value1;key2=value2;...'
  /// 					Example: 'Key1=123;Key2=ABC;Key3=2016-09-16T00:00:00.00Z'
  /// Returns			a new AwsConnectionParams object.
  static AwsConnectionParams fromString(String line) {
    var map = StringValueMap.fromString(line);
    return AwsConnectionParams(map);
  }

  /// Validates this connection parameters
  ///
  ///  -  correlationId     (optional) transaction id to trace execution through call chain.
  /// Returns   Future that return null if validation passed successfully.
  /// Throws ConfigException
  Future validate(String correlationId) async {
    var arn = getArn();
    if (arn == 'arn:aws::::') {
      throw ConfigException(
          correlationId, 'NO_AWS_CONNECTION', 'AWS connection is not set');
    }

    if (getAccessId() == null) {
      throw ConfigException(correlationId, 'NO_ACCESS_ID',
          'No access_id is configured in AWS credential');
    }

    if (getAccessKey() == null) {
      throw ConfigException(correlationId, 'NO_ACCESS_KEY',
          'No access_key is configured in AWS credential');
    }
  }

  /// Retrieves AwsConnectionParams from configuration parameters.
  /// The values are retrieves from 'connection' and 'credential' sections.
  ///
  ///  -  [config] 	configuration parameters
  /// Returns			the generated AwsConnectionParams object.
  ///
  /// See [[mergeConfigs]]
  static AwsConnectionParams fromConfig(ConfigParams config) {
    var result = AwsConnectionParams();

    var credentials = CredentialParams.manyFromConfig(config);
    for (var credential in credentials) {
      result.append(credential);
    }

    var connections = ConnectionParams.manyFromConfig(config);
    for (var connection in connections) {
      result.append(connection);
    }

    return result;
  }

  /// Retrieves AwsConnectionParams from multiple configuration parameters.
  /// The values are retrieves from 'connection' and 'credential' sections.
  ///
  ///  -  [configs] 	a list with configuration parameters
  /// Returns			the generated AwsConnectionParams object.
  ///
  /// See [[fromConfig]]

  static AwsConnectionParams mergeConfigs(List<ConfigParams> configs) {
    var config = ConfigParams.mergeConfigs(configs);
    return AwsConnectionParams(config);
  }
}
