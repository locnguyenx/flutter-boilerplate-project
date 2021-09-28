/// refer to https://mobx.netlify.app/guides/cheat-sheet/
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobx/mobx.dart';
import 'package:flutterapp/models/models.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {

  // constructor:---------------------------------------------------------------
  _AuthStore() {
    // setting up disposers
    _setupDisposers();
    firebaseUserStream = ObservableStream(this.user);
    firestoreUserStream = ObservableStream(streamFirestoreUser());

    // listen on the Stream to do reaction
    firebaseUserStream.listen((data) { this.firebaseUser = data; });
    firestoreUserStream.listen((data) { this.firestoreUser = data; });
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    /// refer to https://mobx.netlify.app/guides/cheat-sheet/, section Adding reactions
    /// Reactions react to changes in observables, and return disposer
    /// type = reaction: will start tracking only after the first change
    /// ReactionDisposer reaction<T>(T Function(Reaction) fn, void Function(T) effect)
    /// Monitors the observables used inside the fn() function and runs the effect()
    /// when the tracking function returns a different value. Only the observables inside fn() are tracked.
    _disposers = [
      // can't use reaction with firebaseUserStream
      // reaction((_) => firebaseUserStream, handleAuthChanged), // do handleAuthChanged() whenever firebaseUserStream changes
      reaction((_) => firebaseUser, handleAuthChanged), // do handleAuthChanged() whenever firebaseUser changes
      // don't use this getter, cause exception Field 'firebaseUserStream' has not been initialized
      // reaction((_) => firebaseUserValue, (msg) => print('Reaction 3 fires firebaseUserValue[$msg]'))
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<bool> emptyLoginResponse =
      ObservableFuture.value(false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String userName = '';

  // store variables:-----------------------------------------------------------
  String userEmail = 'test3@abc.com';
  String password = '123456';
  String confirmPassword = '';

  @observable
  bool success = false;

  @observable
  bool admin = false;

  @observable
  ObservableFuture<bool> loginFuture = emptyLoginResponse;

  late final ObservableStream<User?> firebaseUserStream;
  late final ObservableStream<UserModel?> firestoreUserStream;


  /// reactive inside this store only, should have a reaction
  @observable
  User? firebaseUser;

  /// will be used in UI, need to be reactive
  @observable
  UserModel? firestoreUser;

  @computed
  User? get firebaseUserValue => this.firebaseUserStream.value;

  @computed
  UserModel? get firestoreUserValue => this.firestoreUserStream.value;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  /// Firebase user one-time fetch
  /// Reference: https://firebase.flutter.dev/docs/auth/usage#user-management
  /// Usage: internal use only, so don't need @computed
  Future<User> get getUser async => _auth.currentUser!;

  /// Firebase user a realtime stream
  /// Usage:
  /// - internal use only, so don't need @computed (use firebaseUserStream instead)
  /// - used in UI inside a Observer, in this case need
  Stream<User?> get user => _auth
      .authStateChanges(); // Firebase-subscribe to listen to authentication state changes

  // actions:-------------------------------------------------------------------

  @action
  handleAuthChanged(_firebaseUser) async {
    print('*** AuthStore handleAuthChanged: firebaseUser[$_firebaseUser] id[${_firebaseUser?.uid}]');
    //get user data from firestore
    if (_firebaseUser?.uid != null) {
      // transfrom from Stream to a reactive UserModel variable => use ObservableStream<UserModel>
      // don't need this, should do listen on Stream
      // firestoreUser = firestoreUserStream.value;
      print('=== handleAuthChanged: firestoreUser[$firestoreUser] id[${firebaseUser?.uid}]');
      await checkAdmin();
    }

    if (_firebaseUser == null) {
      print('Send to Signin');
      //Get.offAll(SignInUI());
    } else {
      print('Send to Home');
      //Get.offAll(HomeUI());
    }
  }

  /**
   *  Streams the firestore user from the firestore collection
   *  Usage:
   *  - If UI use StreamBuilder: use this function to get stream
   *  - Otherwise: use this to fetch into firestoreUser (UserModel)
    */
  Stream<UserModel> streamFirestoreUser() {
    print('streamFirestoreUser()');
    return _db
        .doc('/users/${firebaseUser?.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()!));
  }

  /// get the firestore user from the firestore collection
  /// LocNX: @TODO in UI, use this instead of firestoreUser
  Future<UserModel> getFirestoreUser() {
    return _db.doc('/users/${firebaseUser?.uid}').get().then(
        (documentSnapshot) => UserModel.fromMap(documentSnapshot.data()!));
  }

  //Method to handle user sign in using email and password
  @action
  signInWithEmailAndPassword({String? userEmail, String? password}) async {
    // showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: userEmail ?? this.userEmail, password: password ?? this.password);
      success = true;
      loginFuture = ObservableFuture.value(true);
      print('*** AuthController signInWithEmailAndPassword login successfully');
    } catch (error) {
      success = false;
      print(
          '*** AuthController signInWithEmailAndPassword login error: ${error}');
      /*hideLoadingIndicator();
      Get.snackbar('auth.signInErrorTitle', 'auth.signInError',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
       */
    }
  }

  // User registration using email and password
  registerWithEmailAndPassword() async {
    // showLoadingIndicator();
    try {
      await _auth
          .createUserWithEmailAndPassword(email: userEmail, password: password)
          .then((result) async {
        print('uID: ' + result.user!.uid.toString());
        print('email: ' + result.user!.email.toString());

        //create the new user object
        UserModel _newUser = UserModel(
            uid: result.user!.uid,
            email: result.user!.email!,
            name: userName,
            photoUrl: '');

        //create the user in firestore
        _createUserFirestore(_newUser, result.user!);
        // hideLoadingIndicator();
      });
    } on FirebaseAuthException catch (error) {
      /*
      hideLoadingIndicator();
      Get.snackbar('auth.signUpErrorTitle', error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
       */
    }
  }

  //handles updating the user when updating profile
  @action
  Future<void> updateUser(
      UserModel user, String oldEmail, String password) async {
    String _authUpdateUserNoticeTitle = 'auth.updateUserSuccessNoticeTitle';
    String _authUpdateUserNotice = 'auth.updateUserSuccessNotice';
    try {
      //showLoadingIndicator();
      try {
        await _auth
            .signInWithEmailAndPassword(email: oldEmail, password: password)
            .then((_firebaseUser) {
          _firebaseUser.user!
              .updateEmail(user.email)
              .then((value) => _updateUserFirestore(user, _firebaseUser.user!));
        });
      } catch (err) {
        print('Caught error: $err');
        //not yet working, see this issue https://github.com/delay/flutter_starter/issues/21
        if (err ==
            "Error: [firebase_auth/email-already-in-use] The email address is already in use by another account.") {
          _authUpdateUserNoticeTitle = 'auth.updateUserEmailInUse';
          _authUpdateUserNotice = 'auth.updateUserEmailInUse';
        } else {
          _authUpdateUserNoticeTitle = 'auth.wrongPasswordNotice';
          _authUpdateUserNotice = 'auth.wrongPasswordNotice';
        }
      }
      /*
      hideLoadingIndicator();
      Get.snackbar(_authUpdateUserNoticeTitle, _authUpdateUserNotice,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);

       */
    } on PlatformException catch (error) {
      //List<String> errors = error.toString().split(',');
      // print("Error: " + errors[1]);
      //hideLoadingIndicator();
      print(error.code);
      String authError;
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          authError = 'auth.wrongPasswordNotice';
          break;
        default:
          authError = 'auth.unknownError';
          break;
      }

/*
      Get.snackbar('auth.wrongPasswordNoticeTitle', authError,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);

 */
    }
  }

  //updates the firestore user in users collection
  @action
  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').update(user.toJson());
  }

  //create the firestore user in users collection
  @action
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/users/${_firebaseUser.uid}').set(user.toJson());
  }

  //password reset email
  Future<void> sendPasswordResetEmail() async {
    //showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: userEmail);
      /*
      hideLoadingIndicator();
      Get.snackbar(
          'auth.resetPasswordNoticeTitle', 'auth.resetPasswordNotice',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);

       */
    } on FirebaseAuthException catch (error) {
      /*
      hideLoadingIndicator();
      Get.snackbar('auth.resetPasswordFailed', error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);

       */
    }
  }

  //check if user is an admin user
  @action
  checkAdmin() async {
    await getUser.then((user) async {
      DocumentSnapshot adminRef =
          await _db.collection('admin').doc(user.uid).get();
      if (adminRef.exists) {
        admin = true;
      } else {
        admin = false;
      }
    });
  }

  // Sign out
  @action
  Future<void> signOut() {
    loginFuture = ObservableFuture.value(false);
    return _auth.signOut();
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
