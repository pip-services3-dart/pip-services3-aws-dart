// import { Descriptor } from 'package:pip_services3_commons-node';
// import { FilterParams } from 'package:pip_services3_commons-node';
// import { PagingParams } from 'package:pip_services3_commons-node';
// import { DataPage } from 'package:pip_services3_commons-node';
// import { IdGenerator } from 'package:pip_services3_commons-node';
// import { ICommandable } from 'package:pip_services3_commons-node';
// import { CommandSet } from 'package:pip_services3_commons-node';

// import { IDummyController } from './IDummyController';
// import { DummyCommandSet } from './DummyCommandSet';
// import { Dummy } from './Dummy';

// export class DummyController implements IDummyController, ICommandable {
// 	private _commandSet: DummyCommandSet;
//     private readonly _entities: Dummy[] = [];

// 	public getCommandSet(): CommandSet {
// 		if (this._commandSet == null)
// 			this._commandSet = new DummyCommandSet(this);
// 		return this._commandSet;
// 	}

// 	public getPageByFilter(String correlationId, filter: FilterParams, paging: PagingParams, 
// 		callback: (err: any, result: DataPage<Dummy>) => void): void {
		
// 		filter = filter != null ? filter : new FilterParams();
// 		let key: string = filter.getAsNullableString("key");
		
// 		paging = paging != null ? paging : new PagingParams();
// 		let skip: number = paging.getSkip(0);
// 		let take: number = paging.getTake(100);
		
// 		let result: Dummy[] = [];
// 		for (var i = 0; i < this._entities.length; i++) {
//             let entity: Dummy = this._entities[i];
// 			if (key != null && key != entity.key)
// 				continue;
				
// 			skip--;
// 			if (skip >= 0) continue; 
				
// 			take--;
// 			if (take < 0) break;
				
// 			result.push(entity);
// 		}

// 		callback(null,  new DataPage<Dummy>(result));
// 	}

// 	public getOneById(String correlationId, id: string, callback: (err: any, result: Dummy) => void): void {
// 		for (var i = 0; i < this._entities.length; i++) {
//             let entity: Dummy = this._entities[i];
// 			if (id == entity.id) {
// 				callback(null, entity);
// 				return;
// 			}
// 		}
// 		callback(null, null);
// 	}

// 	public create(String correlationId, entity: Dummy, callback: (err: any, result: Dummy) => void): void {
// 		if (entity.id == null) {
//             entity.id = IdGenerator.nextLong();
//             this._entities.push(entity);
//         }
// 		callback(null, entity);
// 	}

// 	public update(String correlationId, newEntity: Dummy, callback: (err: any, result: Dummy) => void): void {
// 		for(var index = 0; index < this._entities.length; index++) {
// 			let entity: Dummy = this._entities[index];
// 			if (entity.id == newEntity.id) {
// 				this._entities[index] = newEntity;
// 				callback(null, newEntity);
// 				return;
// 			}
// 		}
// 		callback(null, null);
// 	}

// 	public deleteById(String correlationId, id: string, callback: (err: any, result: Dummy) => void): void {
// 		for (var index = 0; index < this._entities.length; index++) {
// 			let entity: Dummy = this._entities[index];
// 			if (entity.id == id) {
// 				this._entities.splice(index, 1);
// 				callback(null, entity);
// 				return;
// 			}
// 		}
// 		callback(null, null);
// 	}

// }