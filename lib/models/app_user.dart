// import 'package:firebase_auth/firebase_auth.dart';

// class AppUser {
//   late final FirebaseAuth auth;
//   FirebaseUser _user;

//   AppUser.instance({this.auth}) {
//     auth.onAuthStateChanged.listen(onAuthStateChanged);
//   }

// }

class AppUser {
 final String uid;

 AppUser({
  required this.uid,
});
}