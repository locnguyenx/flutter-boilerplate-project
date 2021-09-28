/// locnx
/// This is just an example how to create an API that use DioClient or RestClient to do networking handling
/// To create a new API;
/// 1. Create a Model class Abc (abc.dart) in path: lib/models/
/// 2. (optional) create a ModelList of respected Model AbcList
/// 3. Create a AbcApi class (abc_api.dart) in path: lib/data/network/apis/
/// 4. Register new API in Service Locator at path lib/di/components/service_locator.dart
/// 5. get the singleton of this API and use: getIt<AbcApi>()

import 'dart:async';

import 'package:flutterapp/data/network/constants/endpoints.dart';
import 'package:flutterapp/data/network/dio_client.dart';
import 'package:flutterapp/data/network/rest_client.dart';
import 'package:flutterapp/models/post/post_list.dart';

class PostApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  PostApi(this._dioClient, this._restClient);

  /// Returns list of post in response
  Future<PostList> getPosts() async {
    try {
      final res = await _dioClient.get(Endpoints.getPosts);
      return PostList.fromJson(res);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

/// sample api call with default rest client
//  Future<PostsList> getPosts() {
//
//    return _restClient
//        .get(Endpoints.getPosts)
//        .then((dynamic res) => PostsList.fromJson(res))
//        .catchError((error) => throw NetworkException(message: error));
//  }

}
