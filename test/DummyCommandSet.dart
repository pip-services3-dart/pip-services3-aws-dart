// import { CommandSet } from 'package:pip_services3_commons-node';
// import { ICommand } from 'package:pip_services3_commons-node';
// import { Command } from 'package:pip_services3_commons-node';
// import { Parameters } from 'package:pip_services3_commons-node';
// import { FilterParams } from 'package:pip_services3_commons-node';
// import { PagingParams } from 'package:pip_services3_commons-node';
// import { ObjectSchema } from 'package:pip_services3_commons-node';
// import { Schema} from 'package:pip_services3_commons-node';
// import { MapSchema } from 'package:pip_services3_commons-node';
// import { TypeCode } from 'package:pip_services3_commons-node';
// import { FilterParamsSchema } from 'package:pip_services3_commons-node';
// import { PagingParamsSchema } from 'package:pip_services3_commons-node';

// import { Dummy } from './Dummy';
// import { IDummyController } from './IDummyController';
// import { DummySchema } from './DummySchema';

// export class DummyCommandSet extends CommandSet {
//     private _controller: IDummyController;

// 	constructor(controller: IDummyController) {
// 		super();

// 		this._controller = controller;

// 		this.addCommand(this.makeGetPageByFilterCommand());
// 		this.addCommand(this.makeGetOneByIdCommand());
// 		this.addCommand(this.makeCreateCommand());
// 		this.addCommand(this.makeUpdateCommand());
// 		this.addCommand(this.makeDeleteByIdCommand());
// 	}

// 	private makeGetPageByFilterCommand(): ICommand {
// 		return new Command(
// 			"get_dummies",
// 			new ObjectSchema(true)
//                 .withOptionalProperty("filter", new FilterParamsSchema())
//                 .withOptionalProperty("paging", new PagingParamsSchema()),
// 			(String correlationId, args: Parameters, callback: (err: any, result: any) => void) => {
// 				let filter = FilterParams.fromValue(args.get("filter"));
// 				let paging = PagingParams.fromValue(args.get("paging"));
// 				this._controller.getPageByFilter(correlationId, filter, paging, callback);
// 			}
// 		);
// 	}

// 	private makeGetOneByIdCommand(): ICommand {
// 		return new Command(
// 			"get_dummy_by_id",
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy_id", TypeCode.String),
// 			(String correlationId, args: Parameters, callback: (err: any, result: any) => void) => {
// 				let id = args.getAsString("dummy_id");
// 				this._controller.getOneById(correlationId, id, callback);
// 			}
// 		);
// 	}

// 	private makeCreateCommand(): ICommand {
// 		return new Command(
// 			"create_dummy",
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy", new DummySchema()),
// 			(String correlationId, args: Parameters, callback: (err: any, result: any) => void) => {
// 				let entity: Dummy = args.get("dummy");
// 				this._controller.create(correlationId, entity, callback);
// 			}
// 		);
// 	}

// 	private makeUpdateCommand(): ICommand {
// 		return new Command(
// 			"update_dummy",
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy", new DummySchema()),
// 			(String correlationId, args: Parameters, callback: (err: any, result: any) => void) => {
// 				let entity: Dummy = args.get("dummy");
// 				this._controller.update(correlationId, entity, callback);
// 			}
// 		);
// 	}

// 	private makeDeleteByIdCommand(): ICommand {
// 		return new Command(
// 			"delete_dummy",
//             new ObjectSchema(true)
//                 .withRequiredProperty("dummy_id", TypeCode.String),
// 			(String correlationId, args: Parameters, callback: (err: any, result: any) => void) => {
// 				let id = args.getAsString("dummy_id");
// 				this._controller.deleteById(correlationId, id, callback);
// 			}
// 		);
// 	}

// }