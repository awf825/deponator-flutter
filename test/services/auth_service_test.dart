// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deponator_flutter/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:deponator_flutter/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test/test.dart';

// https://pub.dev/packages/fake_cloud_firestore

void main() async {
  final mockAuthService = MockAuthService();
  test('signIn should attach a valid uid', () async {
    final result = await mockAuthService.signIn("test1@test.com", "password");
    expect(result.user!.uid, isNotEmpty);
  });
}

class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockAuthService extends Mock implements AuthService {
  final MockFirebaseAuth _mockAuth = MockFirebaseAuth();

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
  Future<UserCredential> signIn(email, password) async {
    UserCredential result = await _mockAuth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    return result;
  }
}