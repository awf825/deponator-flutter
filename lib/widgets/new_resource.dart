import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/auth_service.dart';

class NewResource extends StatefulWidget {
  const NewResource({ super.key });

  @override
  State<StatefulWidget> createState() {
    return _NewResourceState();
  }
}

class _NewResourceState extends State<NewResource> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredDescription = '';
  var _isSending = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _authService = AuthService();

  void _saveResource() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final data = {
        "uid": _authService.currentUser!.uid, 
        "name": _enteredName, 
        "description": _enteredDescription
      };

      _db
        .collection("resources")
        .add(data)
        .then(
          (documentSnapshot) => print("Added Resource with ID: ${documentSnapshot.id}")
        );

      if (!mounted) { // i.e !context.mounted
        return;
      }

      Navigator.of(context).pop(
        Resource(
          uid: _authService.currentUser!.uid, 
          name: _enteredName, 
          description: _enteredDescription
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new resource.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 100,
                decoration: const InputDecoration(
                  label: Text('Name')
                ),
                initialValue: _enteredName,
                validator: (value) {
                  if (
                    value == null || 
                    value.isEmpty || 
                    value.trim().length <= 1 || 
                    value.trim().length > 100
                  ) {
                    return 'Must be between 1 and 100 characters.';
                  }
                  return null; // returning null means validator deems input valid
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Description')
                ),
                initialValue: _enteredDescription,
                validator: (value) {
                  if (
                    value == null || 
                    value.isEmpty || 
                    value.trim().length <= 1
                  ) {
                    return 'Must provide a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredDescription = value!;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // make sure row content is pushed all the way to the right
                children: [
                  // setting TextButton's onPressed to null will disable the button
                  TextButton(
                    onPressed: _isSending ? null : () {
                      _formKey.currentState!.reset();
                    }, 
                    child: const Text('Reset')
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveResource, 
                    child: _isSending 
                      ? const SizedBox(
                        height: 16, 
                        width: 16, 
                        child: CircularProgressIndicator()
                      ) : const Text('Add Resource')
                  )
                ],
              )
            ],
          ),
        )
      )
    );
  }
}