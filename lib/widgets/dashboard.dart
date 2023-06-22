import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:deponator_flutter/services/auth_service.dart';
import 'package:deponator_flutter/widgets/new_resource.dart';
import 'package:deponator_flutter/models/resource.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({ super.key });

  @override
  State<Dashboard> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  final List<Resource> _resources = [];
  late Future<List<Resource>> _loadedItems;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<Resource>> _loadItems() async {
    final List<Resource> loadedItems = [];
    await _db
      .collection("resources")
      .where("uid", isEqualTo: _authService.currentUser!.uid)
      .get().then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            final docData = docSnapshot.data();
            loadedItems.add(
              Resource(
                uid: docData['uid'],
                name: docData['name'],
                description: docData['description']
              )
            );
          }
        },
        onError: (e) => print("Error completing: $e"),
    );
    return loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<Resource>(
      MaterialPageRoute(
        builder: (ctx) => const NewResource(),
      )
    );

    if (newItem == null) {
      return; 
    }

    setState(() {
      _resources.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem
          ),
          IconButton(
            onPressed: () {
              AuthService().logOut();
            }, 
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            )
          )
        ]
      ),
      body: FutureBuilder<List<Resource>>(
        future: _loadedItems,
        builder: (context, snapshot) {
          // waiting on promise/future
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // promise/future has been rejected
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          // // future has successfully resolved 
          if (snapshot.data!.isEmpty) {
            return  const Center(
              child: Text('No items added yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              // onDismissed: (direction) {
              //   _removeItem(snapshot.data![index]);
              // },
              key: ValueKey(snapshot.data![index].name),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: const SizedBox(
                  width: 24,
                  height: 24
                ),
              ),
            )
          );
        }
      )
    );
  }
}

// void _removeItem(GroceryItem item) async {
//   final index =  _groceryItems.indexOf(item);
//   setState(() {
//     _groceryItems.remove(item);
//   });

//   final url = Uri.https(
//     'flutter-prep-3abdd-default-rtdb.firebaseio.com', 
//     'shopping-list/${item.id}.json'
//   );

//   final response = await http.delete(url);

//   if (response.statusCode >= 400) {
//     setState(() {
//       _groceryItems.insert(index, item);
//     });
//   }
// }