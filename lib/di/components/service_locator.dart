/**
 * This is a Sevice Locator implemented by GetIt
 * https://pub.dev/packages/get_it
 * https://www.geeksforgeeks.org/service-locator-pattern/
 */
import 'package:flutterapp/data/local/datasources/post/post_datasource.dart';
import 'package:flutterapp/data/network/apis/posts/post_api.dart';
import 'package:flutterapp/data/network/apis/common_api.dart';
import 'package:flutterapp/data/network/dio_client.dart';
import 'package:flutterapp/data/network/rest_client.dart';
import 'package:flutterapp/data/repository.dart';
import 'package:flutterapp/data/sharedpref/shared_preference_helper.dart';
import 'package:flutterapp/di/module/local_module.dart';
import 'package:flutterapp/di/module/network_module.dart';
import 'package:flutterapp/stores/stores.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // factories:-----------------------------------------------------------------
  getIt.registerFactory(() => ErrorStore());
  getIt.registerFactory(() => FormStore());

  // async singletons:----------------------------------------------------------
  getIt.registerSingletonAsync<Database>(() => LocalModule.provideDatabase());
  getIt.registerSingletonAsync<SharedPreferences>(() => LocalModule.provideSharedPreferences());

  // singletons:----------------------------------------------------------------
  getIt.registerSingleton(SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton<Dio>(NetworkModule.provideDio(getIt<SharedPreferenceHelper>()));
  getIt.registerSingleton(DioClient(getIt<Dio>()));
  getIt.registerSingleton(RestClient());

  // api's:---------------------------------------------------------------------
  getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));
  getIt.registerSingleton(CommonApi(getIt<Dio>(), getIt<RestClient>()));

  // data sources
  getIt.registerSingleton(PostDataSource(await getIt.getAsync<Database>()));

  // repository:----------------------------------------------------------------
  getIt.registerSingleton(Repository(
    getIt<CommonApi>(),
    getIt<PostApi>(),
    getIt<SharedPreferenceHelper>(),
    getIt<PostDataSource>(),
  ));

  // stores:--------------------------------------------------------------------
  getIt.registerSingleton(LanguageStore(getIt<Repository>()));
  //getIt.registerSingleton(PostStore(getIt<Repository>()));
  getIt.registerSingleton(ThemeStore(getIt<Repository>()));
  getIt.registerSingleton(UserStore(getIt<Repository>()));

  // initialize Firebase
  await Firebase.initializeApp(); // required WidgetsFlutterBinding.ensureInitialized() in main()
  // @TODO need to check if we need to use registerSingletonAsync, i.e:
  // getIt.registerSingletonAsync(await Firebase.initializeApp());
  // waiting for Firebase initialization and build AuthStore
  AuthStore _authStore = AuthStore();
  getIt.registerSingleton(_authStore);
  print('*** complete registerSingleton _authStore: ${_authStore.userEmail}');
}
