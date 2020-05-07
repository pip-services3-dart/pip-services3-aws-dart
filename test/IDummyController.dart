import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import './Dummy.dart';

abstract class IDummyController {
  Future<DataPage<Dummy>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging);
  Future<Dummy> getOneById(String correlationId, String id);
  Future<Dummy> create(String correlationId, Dummy entity);
  Future<Dummy> update(String correlationId, Dummy entity);
  Future<Dummy> deleteById(String correlationId, String id);
}
