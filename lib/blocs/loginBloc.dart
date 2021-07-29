import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlinestoremanager/validators/loginValidators.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState { IDLE, LOADING, SUCCESS, FAIL }

class loginBloc extends BlocBase with LoginValidators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();
  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword =>
      _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outState => _stateController.stream;
  Stream<bool> get outSubmittedValid => Rx.combineLatest2(
      outEmail, outPassword, (a, b) => a != null && b != null);
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  StreamSubscription<FirebaseUser> _streamSubscription;

  loginBloc() {
    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen(
      (user) async {
        if (user != null) {
          if (await verifyPrivileges(user)) {
            _stateController.add(LoginState.SUCCESS);
          } else {
            FirebaseAuth.instance.signOut();
            _stateController.add(LoginState.FAIL);
          }
        } else {
          _stateController.add(LoginState.IDLE);
        }
      },
    );
  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance
        .collection("admins")
        .document(user.uid)
        .get()
        .then(
      (doc) {
        if (doc.data != null) {
          return true;
        } else {
          return false;
        }
      },
    ).catchError((e) {
      return false;
    });
  }

  void submit() {
    final email = _emailController.value;
    final password = _passwordController.value;
    _stateController.add(LoginState.LOADING);

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      _stateController.add(LoginState.FAIL);
    });
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _stateController.close();
    _streamSubscription.cancel();
    super.dispose();
  }
}
