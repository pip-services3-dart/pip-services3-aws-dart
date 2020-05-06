//  @module connect 
// import { ConfigParams } from 'pip-services3-commons-node';
// import { StringValueMap } from 'pip-services3-commons-node';
// import { ConfigException } from 'pip-services3-commons-node';
// import { CredentialParams } from 'pip-services3-components-node';
// import { ConnectionParams } from 'pip-services3-components-node';

// 
// /// Contains connection parameters to authenticate against Amazon Web Services (AWS)
// /// and connect to specific AWS resource.
// /// 
// /// The class is able to compose and parse AWS resource ARNs.
// /// 
// /// ### Configuration parameters ###
// /// 
// /// - access_id:     application access id
// /// - client_id:     alternative to access_id
// /// - access_key:    application secret key
// /// - client_key:    alternative to access_key
// /// - secret_key:    alternative to access_key
// /// 
// /// In addition to standard parameters [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/classes/auth.credentialparams.html CredentialParams]] may contain any number of custom parameters
// /// 
// /// See [[AwsConnectionResolver]]
// /// 
// /// ### Example ###
// /// 
// ///     let connection = AwsConnectionParams.fromTuples(
// ///         "region", "us-east-1",
// ///         "access_id", "XXXXXXXXXXXXXXX",
// ///         "secret_key", "XXXXXXXXXXXXXXX",
// ///         "service", "s3",
// ///         "bucket", "mybucket"
// ///     );
// ///     
// ///     let region = connection.getRegion();                     // Result: "us-east-1"
// ///     let accessId = connection.getAccessId();                 // Result: "XXXXXXXXXXXXXXX"
// ///     let secretKey = connection.getAccessKey();               // Result: "XXXXXXXXXXXXXXX"
// ///     let pin = connection.getAsNullableString("bucket");      // Result: "mybucket"   
//  
// export class AwsConnectionParams extends ConfigParams {

//     
//     /// Creates an new instance of the connection parameters.
//     /// 
// 	///  -  values 	(optional) an object to be converted into key-value pairs to initialize this connection.
//      
//     public constructor(values: any = null) {
//         super(values);
//     }

//     
//     /// Gets the AWS partition name.
//     /// 
//     /// Returns the AWS partition name.
//      
//     public getPartition(): string {
//         return super.getAsNullableString("partition") || "aws";
//     }

//     
//     /// Sets the AWS partition name.
//     /// 
//     ///  -  value a new AWS partition name.
//      
//     public setPartition(value: string) {
//         super.put("partition", value);
//     }

//     
//     /// Gets the AWS service name.
//     /// 
//     /// Returns the AWS service name.
//      
//     public getService(): string {
//         return super.getAsNullableString("service") || super.getAsNullableString("protocol");
//     }

//     
//     /// Sets the AWS service name.
//     /// 
//     ///  -  value a new AWS service name.
//      
//     public setService(value: string) {
//         super.put("service", value);
//     }

//     
//     /// Gets the AWS region.
//     /// 
//     /// Returns the AWS region.
//      
//     public getRegion(): string {
//         return super.getAsNullableString("region");
//     }

//     
//     /// Sets the AWS region.
//     /// 
//     ///  -  value a new AWS region.
//      
//     public setRegion(value: string) {
//         super.put("region", value);
//     }

//     
//     /// Gets the AWS account id.
//     /// 
//     /// Returns the AWS account id.
//      
//     public getAccount(): string {
//         return super.getAsNullableString("account");
//     }

//     
//     /// Sets the AWS account id.
//     /// 
//     ///  -  value the AWS account id.
//      
//     public setAccount(value: string) {
//         super.put("account", value);
//     }

//     
//     /// Gets the AWS resource type.
//     /// 
//     /// Returns the AWS resource type.
//      
//     public getResourceType(): string {
//         return super.getAsNullableString("resource_type");
//     }

//     
//     /// Sets the AWS resource type.
//     /// 
//     ///  -  value a new AWS resource type.
//      
//     public setResourceType(value: string) {
//         super.put("resource_type", value);
//     }

//     
//     /// Gets the AWS resource id.
//     /// 
//     /// Returns the AWS resource id.
//      
//     public getResource(): string {
//         return super.getAsNullableString("resource");
//     }

//     
//     /// Sets the AWS resource id.
//     /// 
//     ///  -  value a new AWS resource id.
//      
//     public setResource(value: string) {
//         super.put("resource", value);
//     }

//     
//     /// Gets the AWS resource ARN.
//     /// If the ARN is not defined it automatically generates it from other properties.
//     /// 
//     /// Returns the AWS resource ARN.
//      
//     public getArn(): string {
//         let arn = super.getAsNullableString("arn");
//         if (arn) return arn;

//         arn = "arn";
//         let partition = this.getPartition() || "aws";
//         arn += ":" + partition;
//         let service = this.getService() || "";
//         arn += ":" + service;
//         let region = this.getRegion() || "";
//         arn += ":" + region;
//         let account = this.getAccount() || "";
//         arn += ":" + account;
//         let resourceType = this.getResourceType() || "";
//         if (resourceType != "")
//             arn += ":" + resourceType;
//         let resource = this.getResource() || "";
//         arn += ":" + resource;

//         return arn;
//     }

//     
//     /// Sets the AWS resource ARN.
//     /// When it sets the value, it automatically parses the ARN
//     /// and sets individual parameters.
//     /// 
//     ///  -  value a new AWS resource ARN.
//      
//     public setArn(value: string) {
//         super.put("arn", value);

//         if (value != null) {
//             let tokens = value.split(":");
//             this.setPartition(tokens[1]);
//             this.setService(tokens[2]);
//             this.setRegion(tokens[3]);
//             this.setAccount(tokens[4]);
//             if (tokens.length > 6) {
//                 this.setResourceType(tokens[5]);
//                 this.setResource(tokens[6]);
//             } else {
//                 let temp = tokens[5];
//                 let pos = temp.indexOf("/");
//                 if (pos > 0) {
//                     this.setResourceType(temp.substring(0, pos));
//                     this.setResource(temp.substring(pos + 1));
//                 } else {
//                     this.setResourceType(null);
//                     this.setResource(temp);
//                 }
//             }
//         }
//     }

//     
//     /// Gets the AWS access id.
//     /// 
//     /// Returns the AWS access id.
//      
//     public getAccessId(): string {
//         return super.getAsNullableString("access_id") || super.getAsNullableString("client_id");
//     }

//     
//     /// Sets the AWS access id.
//     /// 
//     ///  -  value the AWS access id.
//      
//     public setAccessId(value: string) {
//         super.put("access_id", value);
//     }

//     
//     /// Gets the AWS client key.
//     /// 
//     /// Returns the AWS client key.
//      
//     public getAccessKey(): string {
//         return super.getAsNullableString("access_key") || super.getAsNullableString("client_key");
//     }

//     
//     /// Sets the AWS client key.
//     /// 
//     ///  -  value a new AWS client key.
//      
//     public setAccessKey(value: string) {
//         super.put("access_key", value);
//     }

//     
// 	/// Creates a new AwsConnectionParams object filled with key-value pairs serialized as a string.
// 	/// 
// 	///  -  line 		a string with serialized key-value pairs as "key1=value1;key2=value2;..."
// 	/// 					Example: "Key1=123;Key2=ABC;Key3=2016-09-16T00:00:00.00Z"
// 	/// Returns			a new AwsConnectionParams object.
//      
//     public static fromString(line: string): AwsConnectionParams {
//         let map = StringValueMap.fromString(line);
//         return new AwsConnectionParams(map);
//     }

//     
//     /// Validates this connection parameters 
//     /// 
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     /// Returns a ConfigException or null if validation passed successfully.
//      
//     public validate(correlationId: string): ConfigException {
//         let arn = this.getArn();
//         if (arn == "arn:aws::::") {
//             return new ConfigException(
//                 correlationId, 
//                 "NO_AWS_CONNECTION",
//                 "AWS connection is not set"
//             );
//         }

//         if (this.getAccessId() == null) {
//             return new ConfigException(
//                 correlationId,
//                 "NO_ACCESS_ID",
//                 "No access_id is configured in AWS credential"
//             );
//         }

//         if (this.getAccessKey() == null) {
//             return new ConfigException(
//                 correlationId, 
//                 "NO_ACCESS_KEY", 
//                 "No access_key is configured in AWS credential"
//             );
//         }
//     }

//     
// 	/// Retrieves AwsConnectionParams from configuration parameters.
//     /// The values are retrieves from "connection" and "credential" sections.
// 	/// 
// 	///  -  config 	configuration parameters
// 	/// Returns			the generated AwsConnectionParams object.
// 	/// 
// 	/// See [[mergeConfigs]]
// 	 
//     public static fromConfig(config: ConfigParams): AwsConnectionParams {
//         let result = new AwsConnectionParams();

//         let credentials = CredentialParams.manyFromConfig(config);
//         for (let credential of credentials)
//             result.append(credential);

//         let connections = ConnectionParams.manyFromConfig(config);
//         for (let connection of connections)
//             result.append(connection);

//         return result;
//     }

//     
// 	/// Retrieves AwsConnectionParams from multiple configuration parameters.
//     /// The values are retrieves from "connection" and "credential" sections.
// 	/// 
// 	///  -  configs 	a list with configuration parameters
// 	/// Returns			the generated AwsConnectionParams object.
// 	/// 
// 	/// See [[fromConfig]]
// 	 
//     public static mergeConfigs(...configs: ConfigParams[]): AwsConnectionParams {
//         let config = ConfigParams.mergeConfigs(...configs);
//         return new AwsConnectionParams(config);
//     }
// }