import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import './AwsConnectionParams.dart';

/// Helper class to retrieve AWS connection and credential parameters,
/// validate them and compose a [[AwsConnectionParams]] value.
///
/// ### Configuration parameters ###
///
/// - [connections]:
///     - [discovery_key]:               (optional) a key to retrieve the connection from [IDiscovery]
///     - [region]:                      (optional) AWS region
///     - [partition]:                   (optional) AWS partition
///     - [service]:                     (optional) AWS service
///     - [resource_type]:               (optional) AWS resource type
///     - [resource]:                    (optional) AWS resource id
///     - [arn]:                         (optional) AWS resource ARN
/// - [credentials]:
///     - [store_key]:                   (optional) a key to retrieve the credentials from [ICredentialStore]
///     - [access_id]:                   AWS access/client id
///     - [access_key]:                  AWS access/client id
///
/// ### References ###
///
/// - *:discovery:\*:\*:1.0         (optional) [IDiscovery] services to resolve connections
/// - *:credential-store:\*:\*:1.0  (optional) Credential stores to resolve credentials
///
/// See [ConnectionParams] (in the Pip.Services components package)
/// See [IDiscovery] (in the Pip.Services components package)
///
/// ### Example ###
///
///     var config = ConfigParams.fromTuples([
///         'connection.region', 'us-east1',
///         'connection.service', 's3',
///         'connection.bucket', 'mybucket',
///         'credential.access_id', 'XXXXXXXXXX',
///         'credential.access_key', 'XXXXXXXXXX'
///     ]);
///
///     var connectionResolver = AwsConnectionResolver();
///     connectionResolver.configure(config);
///     connectionResolver.setReferences(references);
///
///     var connection = await connectionResolver.resolve('123');
///         // Now use connection...

class AwsConnectionResolver implements IConfigurable, IReferenceable {
  /// The connection resolver.
  final connectionResolver = ConnectionResolver();

  /// The credential resolver.
  final credentialResolver = CredentialResolver();

  /// Configures component by passing configuration parameters.
  ///
  ///  -  [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    connectionResolver.configure(config);
    credentialResolver.configure(config);
  }

  /// Sets references to dependent components.
  ///
  ///  -  [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    connectionResolver.setReferences(references);
    credentialResolver.setReferences(references);
  }

  /// Resolves connection and credental parameters and generates a single
  /// AWSConnectionParams value.
  ///
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives AWSConnectionParams value 
  /// Throws error.
  ///
  /// See [connect.idiscovery.html IDiscovery] (in the Pip.Services components package)
  Future<AwsConnectionParams> resolve(String correlationId) async {
    var connection = AwsConnectionParams();
    CredentialParams credential;
    var err = await Future.wait([
      () async {
        try {
          var data = await connectionResolver.resolve(correlationId);
          connection.append(data);
        } catch (ex) {
          return ex;
        }
        return null;
      }(),
      () async {
        try {
          var data = await credentialResolver.lookup(correlationId);
          connection.append(data);
        } catch (ex) {
          return ex;
        }
        return null;
      }(),
      () async {
        // Force ARN parsing
        connection.setArn(connection.getArn());
        // Perform validation
        try {
          await connection.validate(correlationId);
        } catch (ex) {
          return ex;
        }
        return null;
      }()
    ]);
    if (err.isNotEmpty) {
      throw err[0];
    }
    return connection;
  }
}
