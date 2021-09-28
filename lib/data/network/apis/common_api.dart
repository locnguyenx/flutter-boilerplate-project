/// locnx
/// This is just an example how to create an API that use DioClient or RestClient to do networking handling
/// To create a new API;
/// 1. Create a Model class Abc (abc.dart) in path: lib/models/
/// 2. (optional) create a ModelList of respected Model AbcList
/// 3. Create a AbcApi class (abc_api.dart) in path: lib/data/network/apis/
/// 4. Register new API in Service Locator at path lib/di/components/service_locator.dart
/// 5. get the singleton of this API and use: getIt<AbcApi>()

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutterapp/data/network/constants/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutterapp/data/network/rest_client.dart';
import 'dart:convert';

class CommonApi {
  // dio instance
  final Dio _dio;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  CommonApi(this._dio, this._restClient);

  /// Returns list of post in response
  Future<bool> doLogin({String? username, String? password}) async {
    try {
      final response = await _dio.post(Endpoints.doLogin,
          data: {'username': username, 'password': password});
        if (response.statusCode == 200) {
          // sucess, save login and return responseMap
          print('======= CommonApi doLogin done:');
          print(response);
          print(response.statusCode);
          print(response.data);
          return true;
        }
        return false;
      } on DioError catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e.response != null) {
          print(e.response!.data);
          print(e.response!.headers);
          print(e.response!.requestOptions);
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          print(e.requestOptions);
          print(e.message);
        }
        throw e;
      }
  }
}
