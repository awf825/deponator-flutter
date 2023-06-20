import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _db = FirebaseFirestore.instance;
final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
      
    _form.currentState!.save();

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, 
          password: _enteredPassword
        );
      } else {
        await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, 
          password: _enteredPassword
        );
        if (_firebase.currentUser != null) {
          final uid = _firebase.currentUser!.uid;
          
          final user = <String, dynamic>{
            "uid": uid,
            "email": _enteredEmail,
            "resources": {},
            "_resources": {}
          };

          _db
          .collection("users")
          .add(user)
          .then(
            (DocumentReference doc) => {
              print('DocumentSnapshot added with ID: ${doc}'),
            }
          ).catchError(
            (error) => {
              throw error,
            }
          );
        };
      }
    } on FirebaseAuthException catch (error) {
      /*
        Scaffold Messenger -> "manages snackbars and materialbanners (bottom and top of screen, 
        respectively) for descendant scaffolds"
      */
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        )
      );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User could not be added to database.'),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || 
                              value.trim().isEmpty || 
                              !value.contains('@')
                              ) {
                                return 'Please entor valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (
                                value == null || 
                                value.trim().length < 6
                              ) {
                                return 'Pass must be at least 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup')
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            }, 
                            child: Text(_isLogin 
                              ? 'Create an account' 
                              : 'I already have an account.'
                            )
                          )
                        ]
                      ),
                    ),
                  )
                )
              ),
            ]
          ),
        ),
      ),
    );

  }
}