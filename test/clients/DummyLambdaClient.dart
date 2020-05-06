// import { FilterParams } from 'package:pip_services3_commons-node';
// import { PagingParams } from 'package:pip_services3_commons-node';
// import { DataPage } from 'package:pip_services3_commons-node';

// import { LambdaClient } from '../../src/clients/LambdaClient';
// import { IDummyClient } from '../IDummyClient';
// import { Dummy } from '../Dummy';

// export class DummyLambdaClient extends LambdaClient implements IDummyClient {

//     public constructor() { 
//         super();
//     }

//     public getDummies(String correlationId, filter: FilterParams, paging: PagingParams,
//         callback: (err: any, result: DataPage<Dummy>) => void): void {
//         this.call(
//             'get_dummies',
//             correlationId,
//             {
//                 filter: filter,
//                 paging: paging
//             },
//             (err, result) => {
//                 callback(err, result);
//             }
//         );
//     }

//     public getDummyById(String correlationId, dummyId: string,
//         callback: (err: any, result: Dummy) => void): void {
//         this.call(
//             'get_dummy_by_id',
//             correlationId,
//             {
//                 dummy_id: dummyId
//             },
//             (err, result) => {
//                 callback(err, result);
//             }
//         );
//     }

//     public createDummy(String correlationId, dummy: any,
//         callback: (err: any, result: Dummy) => void): void {
//         this.call(
//             'create_dummy',
//             correlationId,
//             {
//                 dummy: dummy
//             },
//             (err, result) => {
//                 callback(err, result);
//             }
//         );
//     }

//     public updateDummy(String correlationId, dummy: any,
//         callback: (err: any, result: Dummy) => void): void {
//         this.call(
//             'update_dummy',
//             correlationId,
//             {
//                 dummy: dummy
//             },
//             (err, result) => {
//                 callback(err, result);
//             }
//         );
//     }

//     public deleteDummy(String correlationId, dummyId: string,
//         callback: (err: any, result: Dummy) => void): void {
//         this.call(
//             'delete_dummy',
//             correlationId,
//             {
//                 dummy_id: dummyId
//             },
//             (err, result) => {
//                 callback(err, result);
//             }
//         );
//     }

// }
