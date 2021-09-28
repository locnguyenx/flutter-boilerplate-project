import 'package:flutterapp/ui/home/home.dart';
import 'package:flutterapp/ui/home/postlist.dart';
import 'package:flutterapp/ui/login/login.dart';
import 'package:flutterapp/ui/splash/splash.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiating this object

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomePage(),
  };
}



