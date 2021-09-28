import 'package:flutterapp/constants/app_theme.dart';
import 'package:flutterapp/constants/strings.dart';
import 'package:flutterapp/data/repository.dart';
import 'package:flutterapp/di/components/service_locator.dart';
import 'package:flutterapp/utils/routes/routes.dart';
import 'package:flutterapp/stores/stores.dart';
import 'package:flutterapp/ui/home/home.dart';
import 'package:flutterapp/ui/login/login.dart';
import 'package:flutterapp/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // Create your store as a final variable in a base Widget. This works better
  // with Hot Reload than creating it directly in the `build` function.
  // final ThemeStore _themeStore = ThemeStore(getIt<Repository>());
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final UserStore _userStore = getIt<UserStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  Widget build(BuildContext context) {
    print('======== MyPage build, check login status:');
    print('UserStore status: ${_userStore.isLoggedIn} _themeStore[${_themeStore.darkMode}]');
    /// Don't need to use Provider. Use getIt instead
    return /* MultiProvider(
      providers: [
        Provider<ThemeStore>(create: (_) => _themeStore),
        Provider<PostStore>(create: (_) => _postStore),
        Provider<LanguageStore>(create: (_) => _languageStore),
        //Provider<UserStore>(create: (_) => _userStore),
      ],
      child:*/
        Observer(
        name: 'global-observer',
        builder: (context) {
          print('======== MyPage child (global-observer) build, check authentication status:');
          //print('UserStore status: ${_userStore.isLoggedIn} _themeStore[${_themeStore.darkMode}]');
          print('firebaseUserStream value[${_authStore.firebaseUserStream.value}}] uid[${_authStore.firebaseUserStream.value?.uid}}]');
          print('firebaseUser[${_authStore.firebaseUser}}] uid[${_authStore.firebaseUser?.uid}}]');
          print('getter firebaseUserValue[${_authStore.firebaseUserValue}}] uid[${_authStore.firebaseUserValue?.uid}}]');
          print('firestoreUserStream value[${_authStore.firestoreUserStream.value}}] uid[${_authStore.firestoreUserStream.value?.uid}}]');
          print('firestoreUser[${_authStore.firestoreUser}}] uid[${_authStore.firestoreUser?.uid}}]');
          print('getter firestoreUserValue[${_authStore.firestoreUserValue}}] uid[${_authStore.firestoreUserValue?.uid}}]');

          _authStore.getFirestoreUser().then((data) => print('getFirestoreUser[$data]'));

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Strings.appName,
            theme: _themeStore.darkMode ? themeDataDark : themeData,
            routes: Routes.routes,
            locale: Locale(_languageStore.locale),
            supportedLocales: _languageStore.supportedLanguages
                .map((language) => Locale(language.locale!, language.code))
                .toList(),
            localizationsDelegates: [
              // A class which loads the translations from JSON files
              AppLocalizations.delegate,
              // Built-in localization of basic text for Material widgets
              GlobalMaterialLocalizations.delegate,
              // Built-in localization for text direction LTR/RTL
              GlobalWidgetsLocalizations.delegate,
              // Built-in localization of basic text for Cupertino widgets
              GlobalCupertinoLocalizations.delegate,
            ],
            // home: _userStore.isLoggedIn ? HomePage() : LoginScreen(),
            home: (_authStore.firebaseUserStream.value?.uid != null) ? HomePage() : LoginScreen(),
          );
        },
    );
  }
}