import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deponator_flutter/models/app_user.dart';
import 'package:deponator_flutter/services/data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:deponator_flutter/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// void main() {
//   final instance = FakeFirebaseFirestore();
//   await instance.collection('users').add({
//     'username': 'Bob',
//   });
//   final snapshot = await instance.collection('users').get();
//   print(snapshot.docs.length); // 1
//   print(snapshot.docs.first.get('username')); // 'Bob'
//   print(instance.dump());
// }

// https://pub.dev/packages/fake_cloud_firestore

void main() async {
  final mockAuthService = MockAuthService();
  final mockDataService = MockDataService(); 
  test('signIn should attach a valid uid', () async {
    final result = await mockAuthService.signIn("test1@test.com", "password");
    expect(result.user!.uid, isNotEmpty);
    expect(mockAuthService.currentUser, isNotNull);
  });
  test('logout should remove current user', () async {
    await mockAuthService.signIn("test1@test.com", "password");
    await mockAuthService.logOut();
    expect(mockAuthService.currentUser, isNull);
  });

  test('signUp should create a user in firebase; app', () async {
    final result = await mockAuthService.signUp("test2@test.com", "password");
    expect(result.user!.uid, isNotEmpty);
    expect(mockAuthService.currentUser, isNotNull);

    final doc = mockDataService.getMockUser(mockAuthService.currentUser!.uid);
    final snapshot = await doc.get();
    print(snapshot);
  });
}

class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

class MockAuthService extends Mock implements AuthService {
  final MockFirebaseAuth _mockAuth = MockFirebaseAuth();
  final MockDataService _mockDataService = MockDataService();

  AppUser _userFromFirebaseMockUser(User? user) {
    return AppUser(
      uid: user!.uid
    );
  }

  @override
  Stream<AppUser> get user {
    return _mockAuth
      .authStateChanges()
      .map(_userFromFirebaseMockUser);
  }

  @override
  User? get currentUser {
    return _mockAuth.currentUser;
  }

  @override
  Future<UserCredential> signIn(email, password) async {
    UserCredential result = await _mockAuth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    return result;
  }

  @override
  Future<UserCredential> signUp(email, password) async {
    UserCredential result = await _mockAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    if (_mockAuth.currentUser != null) {
      final uid = _mockAuth.currentUser!.uid;
      
      final user = <String, dynamic>{
        "uid": uid,
        "email": email,
        "resources": {},
        "_resources": {}
      };

      _mockDataService.insertMockUser(user);
    }

    return result;
  }

  @override
  logOut() { _mockAuth.signOut(); }
}

class MockDataService extends Mock implements DataService {
  final _mockDb = FakeFirebaseFirestore();

  Future<void> insertMockUser(user) async {
    //   await instance.collection('users').add({
//     'username': 'Bob',
//   });
//   final snapshot = await instance.collection('users').get();

    await _mockDb
      .collection("users")
      .add(user)
      .then(
        (DocumentReference documentSnapshot) => print("<??? -- Mock User Inserted: ${documentSnapshot.id} -- ???>"),
        onError: (e) => print("<!!! -- Error completing: $e -- !!!>"),
      );
  }

  DocumentReference getMockUser(uid) {
    return _mockDb.collection('users').doc(uid);
  }
}