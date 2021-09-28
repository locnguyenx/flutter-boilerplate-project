import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/data/sharedpref/constants/preferences.dart';
import 'package:flutterapp/utils/routes/routes.dart';
import 'package:flutterapp/stores/language/language_store.dart';

import 'package:flutterapp/stores/theme/theme_store.dart';
import 'package:flutterapp/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_dialog/material_dialog.dart';

import 'package:flutterapp/di/components/service_locator.dart';
import 'package:flutterapp/stores/stores.dart';


class HomePage extends StatelessWidget {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final UserStore _userStore = getIt<UserStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  /*
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initializing stores
    /// Don't need to use Provider. Use getIt instead
    //_languageStore = Provider.of<LanguageStore>(context);
    //_themeStore = Provider.of<ThemeStore>(context);
  }
  */

  @override
  Widget build(BuildContext context) {
    print('======== HomePhage build, check login status:');
    // print(' _themeStore[${_themeStore.darkMode}], _userStore info: name[${_userStore.userEmail}] isLoggedIn[${_userStore.isLoggedIn}]');

    /*
    /// authenticate user

    if (!_userStore.isLoggedIn) {
      // @TODO error when doing navigation, must use return PageXXX()
      // Navigator.of(context).pushNamed(Routes.login);
      return LoginScreen();
    }
     */

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFAFAFA),
      elevation: 0,
      title: Text(
        "What would you like to eat?",
        style: TextStyle(
            color: Color(0xFF3a3737),
            fontSize: 16,
            fontWeight: FontWeight.w500),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _buildLanguageButton(context),
      _buildThemeButton(),
      _buildLogoutButton(),
      _buildNotificationButton(context),
    ];
  }

  Widget _buildNotificationButton(BuildContext context) {
    return IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Color(0xFF3a3737),
            ),
            onPressed: () {
              //if (!_userStore.isLoggedIn) {
              if (_authStore.firebaseUserStream.value == null) {
                Navigator.of(context).pushNamed(Routes.login);
              }
              /// @TODO open Notification dialog
            });
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () {
        /* use userstore instead
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.is_logged_in, false);
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        */
        // _userStore.logout();
        _authStore.signOut();
        // don't need to do navigation here, MyApp will listen change of UserStore.isLoggedIn and switch to Home;
      },
      icon: Icon(
        Icons.power_settings_new,
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        _buildLanguageDialog(context);
      },
      icon: Icon(
        Icons.language,
      ),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _handleErrorMessage(),
        _buildMainContent(),
      ],
    );
  }
  // body methods:--------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    return Text("Bottom Navigation Bar");
  }


  Widget _buildMainContent() {
    return Observer(
      builder: (context) {
        return // _postStore.loading ? CustomProgressIndicatorWidget() : Material(child: _buildScrollView());
            Material(child: _buildScrollView());
      },
    );
  }

  Widget _buildScrollView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            "This is Home Page",
            style: TextStyle(
                color: Color(0xFF3a3737),
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _handleErrorMessage() {
    return Observer(
      builder: (context) {
        /*
        if (_postStore.errorStore.errorMessage.isNotEmpty) {
          return _showErrorMessage(_postStore.errorStore.errorMessage);
        }
        return SizedBox.shrink();
         */
        // return _showErrorMessage(context, "User[${_userStore.isLoggedIn}]");
        return _showErrorMessage(context, "User[${_authStore.firebaseUserStream.value?.uid}]");
      },
    );
  }

  // General Methods:-----------------------------------------------------------

  _showErrorMessage(BuildContext context, String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createError(
          message: message,
          title: AppLocalizations.of(context).translate('home_tv_error'),
          duration: Duration(seconds: 3),
        )..show(context);
      }
    });

    return SizedBox.shrink();
  }

  _buildLanguageDialog(BuildContext context) {
    _showDialog<String>(
      context: context,
      child: MaterialDialog(
        borderRadius: 5.0,
        enableFullWidth: true,
        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        headerColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        closeButtonColor: Colors.white,
        enableCloseButton: true,
        enableBackButton: false,
        onCloseButtonClicked: () {
          Navigator.of(context).pop();
        },
        children: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.all(0.0),
                title: Text(
                  object.language!,
                  style: TextStyle(
                    color: _languageStore.locale == object.locale
                        ? Theme.of(context).primaryColor
                        : _themeStore.darkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // change user language based on selected locale
                  _languageStore.changeLanguage(object.locale!);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }
}
