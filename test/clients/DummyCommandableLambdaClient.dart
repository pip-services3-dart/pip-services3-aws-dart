
import 'dart:async';
import 'dart:convert';

import  'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_aws/pip_services3_aws.dart';
import  '../IDummyClient.dart';
import  '../Dummy.dart';

class DummyCommandableLambdaClient extends CommandableLambdaClient implements IDummyClient {

    DummyCommandableLambdaClient(): super('dummy'); 

     @override
  Future<DataPage<Dummy>> getDummies(
      String correlationId, FilterParams filter, PagingParams paging) async {
    var result = await call(
        'get_dummies', correlationId, {'filter': filter.toJson(), 'paging': paging.toJson()});
    if (result == null) {
      return null;
    }
    return DataPage<Dummy>.fromJson(json.decode(result), (item) {
      return Dummy.fromJson(item);
    });
  }

  @override
  Future<Dummy> getDummyById(String correlationId, String dummyId) async {
    var result =
        await call('get_dummy_by_id', correlationId, {'dummy_id': dummyId});
    if (result == null) {
      return null;
    }
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> createDummy(String correlationId, Dummy dummy) async {
    var result = await call('create_dummy', correlationId, {dummy: dummy.toJson()});
    if (result == null) {
      return null;
    }
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> updateDummy(String correlationId, Dummy dummy) async {
    var result = await call('update_dummy', correlationId, {'dummy': dummy.toJson()});
    if (result == null) {
      return null;
    }
    return Dummy.fromJson(json.decode(result));
  }

  @override
  Future<Dummy> deleteDummy(String correlationId, String dummyId) async {
    var result =
        await call('delete_dummy', correlationId, {'dummy_id': dummyId});
    if (result == null) {
      return null;
    }
    return Dummy.fromJson(json.decode(result));
  }

}
