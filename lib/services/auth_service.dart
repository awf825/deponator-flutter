import 'package:deponator_flutter/services/data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deponator_flutter/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _dataService = DataService();

  AppUser _userFromFirebaseUser(User? user) {
    // ignore: unnecessary_null_comparison
    return AppUser(uid: user!.uid);
  }

  Stream<AppUser> get user {
    return _auth
      .authStateChanges()
      .map(_userFromFirebaseUser);
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<void> signUp(email, password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    if (_auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      
      final user = <String, dynamic>{
        "uid": uid,
        "email": email,
        "resources": {},
        "_resources": {}
      };

      _dataService.insertUser(user);
    }
  }

  Future<void> signIn(email, password) async {
    await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  logOut() { _auth.signOut(); }
}