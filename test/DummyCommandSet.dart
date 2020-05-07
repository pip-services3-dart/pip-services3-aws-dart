import 'package:pip_services3_commons/pip_services3_commons.dart';

import './Dummy.dart';
import './IDummyController.dart';
import './DummySchema.dart';

class DummyCommandSet extends CommandSet {
  IDummyController _controller;

  DummyCommandSet(IDummyController controller) : super() {
    _controller = controller;

    addCommand(_makeGetPageByFilterCommand());
    addCommand(_makeGetOneByIdCommand());
    addCommand(_makeCreateCommand());
    addCommand(_makeUpdateCommand());
    addCommand(_makeDeleteByIdCommand());
  }

  ICommand _makeGetPageByFilterCommand() {
    return Command(
        'get_dummies',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        (String correlationId, Parameters args) {
      var filter = FilterParams.fromValue(args.get('filter'));
      var paging = PagingParams.fromValue(args.get('paging'));
      return _controller.getPageByFilter(correlationId, filter, paging);
    });
  }

  ICommand _makeGetOneByIdCommand() {
    return Command('get_dummy_by_id',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var id = args.getAsString('dummy_id');
      return _controller.getOneById(correlationId, id);
    });
  }

  ICommand _makeCreateCommand() {
    return Command('create_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        (String correlationId, Parameters args) {
      var entity = Dummy.fromJson(args.get('dummy'));
      return _controller.create(correlationId, entity);
    });
  }

  ICommand _makeUpdateCommand() {
    return Command('update_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        (String correlationId, Parameters args) {
      var entity = Dummy.fromJson(args.get('dummy'));
      return _controller.update(correlationId, entity);
    });
  }

  ICommand _makeDeleteByIdCommand() {
    return Command('delete_dummy',
        ObjectSchema(true).withRequiredProperty('dummy_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var id = args.getAsString('dummy_id');
      return _controller.deleteById(correlationId, id);
    });
  }
}
