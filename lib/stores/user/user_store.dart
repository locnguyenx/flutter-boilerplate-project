/**
 * LocNX
 * Store is the place to manage App State (https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)
 * NOTE: Store is aka Model of State Management Layer in the pattern
 *    https://suragch.medium.com/flutter-state-management-for-minimalists-4c71a2f2f0c1
 *    It's differenct from ViewModel that this Model doesn't contain page (UI) logic
 *    Store in MobX: https://mobx.netlify.app/guides/stores
 */

import 'package:flutterapp/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

import '../../data/repository.dart';
import '../form/form_store.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // repository instance
  final Repository _repository;

  // store for handling form errors
  final FormErrorStore formErrorStore = FormErrorStore();

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();


  // constructor:---------------------------------------------------------------
  _UserStore(Repository repository) : this._repository = repository {

    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    repository.isLoggedIn.then((value) {
      _isLoggedIn = value;
    });
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<bool> emptyLoginResponse =
  ObservableFuture.value(false);

  // store variables:-----------------------------------------------------------
  @observable
  String userEmail = '';

  String _tempPassword = '';

  // bool to check if current user is logged in
  @observable
  bool _isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  ObservableFuture<bool> loginFuture = emptyLoginResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  // getters:-------------------------------------------------------------------
  bool get isLoggedIn => _isLoggedIn;

  // actions:-------------------------------------------------------------------
  @action
  Future login({String? userEmail, String? password}) async {
    // LocNX debug
    print('===== [UserStore] login() is called');
    final future = _repository.login(userEmail ?? this.userEmail, password!);
    loginFuture = ObservableFuture(future);
    await future.then((value) async {
      if (value) {
        _repository.saveIsLoggedIn(true);
        _isLoggedIn = true;
        this.success = true;
      } else {
        print('failed to login');
      }
    }).catchError((e) {
      print(e);
      _isLoggedIn = false;
      this.success = false;
      throw e;
    });
  }

  @action
  logout() {
    _isLoggedIn = false;
    _repository.saveIsLoggedIn(false);
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}