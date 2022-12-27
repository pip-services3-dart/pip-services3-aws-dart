import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_aws/pip_services3_aws.dart';
import '../IDummyController.dart';
import '../DummyFactory.dart';
import '../DummySchema.dart';
import '../Dummy.dart';

class DummyLambdaFunction extends LambdaFunction {
  IDummyController _controller;

  DummyLambdaFunction() : super('dummy', 'Dummy lambda function') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-dummies', 'controller', 'default', '*', '*'));
    factories.add(DummyFactory());
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    _controller =
        dependencyResolver.getOneRequired<IDummyController>('controller');
  }

  Future _getPageByFilter(params) async {
    return await _controller.getPageByFilter(params['correlation_id'],
        FilterParams(params['filter']), PagingParams(params['paging']));
  }

  Future _getOneById(params) async {
    return await _controller.getOneById(
        params['correlation_id'], params['dummy_id']);
  }

  Future _create(params) async {
    return await _controller.create(
        params['correlation_id'], Dummy.fromJson(params['dummy']));
  }

  Future _update(params) async {
    return await _controller.update(
        params['correlation_id'], Dummy.fromJson(params['dummy']));
  }

  Future _deleteById(params) async {
    return await _controller.deleteById(
        params['correlation_id'], params['dummy_id']);
  }

  @override
  void register() {
    registerAction(
        'get_dummies',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        _getPageByFilter);

    registerAction(
        'get_dummy_by_id',
        ObjectSchema(true).withOptionalProperty('dummy_id', TypeCode.String),
        _getOneById);

    registerAction(
        'create_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        _create);

    registerAction(
        'update_dummy',
        ObjectSchema(true).withRequiredProperty('dummy', DummySchema()),
        _update);

    registerAction(
        'delete_dummy',
        ObjectSchema(true).withOptionalProperty('dummy_id', TypeCode.String),
        _deleteById);
  }
}

//export const handler = DummyLambdaFunction().getHandler();
