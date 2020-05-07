import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import './IDummyController.dart';
import './DummyCommandSet.dart';
import './Dummy.dart';

class DummyController implements IDummyController, ICommandable {
  DummyCommandSet _commandSet;
  final _entities = <Dummy>[];

  @override
  CommandSet getCommandSet() {
    _commandSet ??= DummyCommandSet(this);
    return _commandSet;
  }

  @override
  Future<DataPage<Dummy>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) async {
    filter ??= FilterParams();
    var key = filter.getAsNullableString('key');

    paging ??= PagingParams();
    var skip = paging.getSkip(0);
    var take = paging.getTake(100);

    var result = <Dummy>[];
    for (var i = 0; i < _entities.length; i++) {
      var entity = _entities[i];
      if (key != null && key != entity.key) {
        continue;
      }

      skip--;
      if (skip >= 0) continue;

      take--;
      if (take < 0) break;

      result.add(entity);
    }

    return DataPage<Dummy>(result, result.length);
  }

  @override
  Future<Dummy> getOneById(String correlationId, String id) async {
    for (var i = 0; i < _entities.length; i++) {
      var entity = _entities[i];
      if (id == entity.id) {
        return entity;
      }
    }
    return null;
  }

  @override
  Future<Dummy> create(String correlationId, Dummy entity) async {
    if (entity.id == null || entity.id.isEmpty) {
      entity.id = IdGenerator.nextLong();
      _entities.add(entity);
    }
    return entity;
  }

  @override
  Future<Dummy> update(String correlationId, Dummy newEntity) async {
    for (var index = 0; index < _entities.length; index++) {
      var entity = _entities[index];
      if (entity.id == newEntity.id) {
        _entities[index] = newEntity;
        return newEntity;
      }
    }
    return null;
  }

  @override
  Future<Dummy> deleteById(String correlationId, String id) async {
    for (var index = 0; index < _entities.length; index++) {
      var entity = _entities[index];
      if (entity.id == id) {
        _entities.removeAt(index);
        return entity;
      }
    }
    return null;
  }
}
