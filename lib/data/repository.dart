/// locnx
/// This is the single place to handle data processing (data service) of the app
/// To add a new resource (model) into the repository ;
/// 1. Create a Data Model
/// 2. a. Create respected Api class (refer to post_api.dart for example) if this is network data
///    b. Create a DataSource in local/datasources if this is local data
/// 3. Add new functions here to manipulate data
/// 4. Add a store to manage the state if needed
///
///  DATA ACCESSING FLOW:
///   UI => Store (Model) => Repository =>
///     => API (for network)
///     => XXX_DataSource to update local storage => DB
///
/// NOTE:
/// 1. Repository is aka Storage Service of Service Layer in the pattern
///    https://suragch.medium.com/flutter-state-management-for-minimalists-4c71a2f2f0c1
/// 2. Store in MobX: https://mobx.netlify.app/guides/stores

import 'dart:async';

import 'package:flutterapp/data/local/datasources/post/post_datasource.dart';
import 'package:flutterapp/data/sharedpref/shared_preference_helper.dart';
import 'package:flutterapp/models/post/post.dart';
import 'package:flutterapp/models/post/post_list.dart';
import 'package:sembast/sembast.dart';

import 'local/constants/db_constants.dart';
import 'network/apis/posts/post_api.dart';
import 'network/apis/common_api.dart';

class Repository {
  // data source object
  final PostDataSource _postDataSource;

  // api objects
  final PostApi _postApi;
  final CommonApi _commonApi;

  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;

  // constructor
  Repository(this._commonApi, this._postApi, this._sharedPrefsHelper, this._postDataSource);

  // Post: ---------------------------------------------------------------------
  Future<PostList> getPosts() async {
    // check to see if posts are present in database, then fetch from database
    // else make a network call to get all posts, store them into database for
    // later use

    return await _postApi.getPosts().then((postsList) {
      postsList.posts?.forEach((post) {
        _postDataSource.insert(post);
      });

      return postsList;
    }).catchError((error) => throw error);
  }

  Future<List<Post>> findPostById(int id) {
    //creating filter
    List<Filter> filters = [];

    //check to see if dataLogsType is not null
    Filter dataLogTypeFilter = Filter.equals(DBConstants.FIELD_ID, id);
    filters.add(dataLogTypeFilter);

    //making db call
    return _postDataSource
        .getAllSortedByFilter(filters: filters)
        .then((posts) => posts)
        .catchError((error) => throw error);
  }

  Future<int> insert(Post post) => _postDataSource
      .insert(post)
      .then((id) => id)
      .catchError((error) => throw error);

  Future<int> update(Post post) => _postDataSource
      .update(post)
      .then((id) => id)
      .catchError((error) => throw error);

  Future<int> delete(Post post) => _postDataSource
      .update(post)
      .then((id) => id)
      .catchError((error) => throw error);


  // Login:---------------------------------------------------------------------
  /**
   * LocNX
   * @TODO: call API to do login
   */
  Future<bool> login(String email, String password) async {
    print('===== [Repository] login() is called');
    return await Future.delayed(Duration(seconds: 2), ()=> true);
    /*
    return await _commonApi.doLogin(username:email, password:password).then((result) {
      return result;
    }).catchError((error) => throw error);
    */
  }

  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;

  // Theme: --------------------------------------------------------------------
  Future<void> changeBrightnessToDark(bool value) =>
      _sharedPrefsHelper.changeBrightnessToDark(value);

  bool get isDarkMode => _sharedPrefsHelper.isDarkMode;

  // Language: -----------------------------------------------------------------
  Future<void> changeLanguage(String value) =>
      _sharedPrefsHelper.changeLanguage(value);

  String? get currentLanguage => _sharedPrefsHelper.currentLanguage;
}