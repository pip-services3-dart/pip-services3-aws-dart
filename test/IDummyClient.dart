import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import './Dummy.dart';

abstract class IDummyClient {
  Future<DataPage<Dummy>> getDummies(
      String correlationId, FilterParams filter, PagingParams paging);
  Future<Dummy> getDummyById(String correlationId, String dummyId);
  Future<Dummy> createDummy(String correlationId, Dummy dummy);
  Future<Dummy> updateDummy(String correlationId, Dummy dummy);
  Future<Dummy> deleteDummy(String correlationId, String dummyId);
}
