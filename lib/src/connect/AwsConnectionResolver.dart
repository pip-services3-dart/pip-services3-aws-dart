//  @module connect 
//  @hidden 
// let _ = require('lodash');
//  @hidden 
// let async = require('async');

// import { IConfigurable } from 'pip-services3-commons-node';
// import { IReferenceable } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { ConnectionResolver } from 'pip-services3-components-node';
// import { ConnectionParams } from 'pip-services3-components-node';
// import { CredentialResolver } from 'pip-services3-components-node';
// import { CredentialParams } from 'pip-services3-components-node';

// import { AwsConnectionParams } from './AwsConnectionParams';

// 
// /// Helper class to retrieve AWS connection and credential parameters,
// /// validate them and compose a [[AwsConnectionParams]] value.
// /// 
// /// ### Configuration parameters ###
// /// 
// /// - connections:                   
// ///     - discovery_key:               (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
// ///     - region:                      (optional) AWS region
// ///     - partition:                   (optional) AWS partition
// ///     - service:                     (optional) AWS service
// ///     - resource_type:               (optional) AWS resource type
// ///     - resource:                    (optional) AWS resource id
// ///     - arn:                         (optional) AWS resource ARN
// /// - credentials:    
// ///     - store_key:                   (optional) a key to retrieve the credentials from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/auth.icredentialstore.html ICredentialStore]]
// ///     - access_id:                   AWS access/client id
// ///     - access_key:                  AWS access/client id
// /// 
// /// ### References ###
// /// 
// /// - <code>\*:discovery:\*:\*:1.0</code>         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connections
// /// - <code>\*:credential-store:\*:\*:1.0</code>  (optional) Credential stores to resolve credentials
// /// 
// /// See [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/classes/connect.connectionparams.html ConnectionParams]] (in the Pip.Services components package)
// /// See [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] (in the Pip.Services components package)
// /// 
// /// ### Example ###
// /// 
// ///     let config = ConfigParams.fromTuples(
// ///         "connection.region", "us-east1",
// ///         "connection.service", "s3",
// ///         "connection.bucket", "mybucket",
// ///         "credential.access_id", "XXXXXXXXXX",
// ///         "credential.access_key", "XXXXXXXXXX"
// ///     );
// ///     
// ///     let connectionResolver = new AwsConnectionResolver();
// ///     connectionResolver.configure(config);
// ///     connectionResolver.setReferences(references);
// ///     
// ///     connectionResolver.resolve("123", (err, connection) => {
// ///         // Now use connection...
// ///     });
//  
// export class AwsConnectionResolver implements IConfigurable, IReferenceable {
//     
//     /// The connection resolver.
//      
//     protected _connectionResolver: ConnectionResolver = new ConnectionResolver();
//     
//     /// The credential resolver.
//      
//     protected _credentialResolver: CredentialResolver = new CredentialResolver();

//     
//     /// Configures component by passing configuration parameters.
//     /// 
//     ///  -  config    configuration parameters to be set.
//      
//     public configure(config: ConfigParams): void {
//         this._connectionResolver.configure(config);
//         this._credentialResolver.configure(config);
//     }

//     
// 	/// Sets references to dependent components.
// 	/// 
// 	///  -  references 	references to locate the component dependencies. 
//      
//     public setReferences(references: IReferences): void {
//         this._connectionResolver.setReferences(references);
//         this._credentialResolver.setReferences(references);
//     }

//     
//     /// Resolves connection and credental parameters and generates a single
//     /// AWSConnectionParams value.
//     /// 
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  callback 			callback function that receives AWSConnectionParams value or error.
//     /// 
//     /// See [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] (in the Pip.Services components package)
//      
//     public resolve(correlationId: string,
//         callback: (err: any, connection: AwsConnectionParams) => void): void {
//         let connection = new AwsConnectionParams();
//         let credential = null;

//         async.series([
//             (callback) => {
//                 this._connectionResolver.resolve(correlationId, (err: any, data: ConnectionParams) => {
//                     if (err == null && data != null)
//                         connection.append(data);
//                     callback(err);
//                 });
//             },
//             (callback) => {
//                 this._credentialResolver.lookup(correlationId, (err: any, data: CredentialParams) => {
//                     if (err == null && data != null)
//                         connection.append(data);
//                     callback(err);
//                 });
//             },
//             (callback) => {
//                 // Force ARN parsing
//                 connection.setArn(connection.getArn());

//                 // Perform validation
//                 let err = connection.validate(correlationId);

//                 callback(err);
//             }
//         ], (err) => {
//             connection = err == null ? connection : null;
//             callback(err, connection);
//         });
//     }

// }