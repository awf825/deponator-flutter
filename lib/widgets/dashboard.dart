import 'package:deponator_flutter/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:deponator_flutter/services/auth_service.dart';
import 'package:deponator_flutter/widgets/new_resource.dart';
import 'package:deponator_flutter/models/resource.dart';

import 'package:deponator_flutter/screens/resource_grid.dart';

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
  final _authService = AuthService();
  final _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<Resource>> _loadItems() async {
    final List<Resource> loadedItems = [];
    final loadedItemsQuerySnapshot = await _dataService.loadItemsByUserId(
      _authService.currentUser!.uid,
    );

    for (var docSnapshot in loadedItemsQuerySnapshot.docs) {
      final docData = docSnapshot.data();
      loadedItems.add(
        Resource(
          uid: docData['uid'],
          name: docData['name'],
          description: docData['description']
        )
      );
    }
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

          return ResourceGridScreen(items: snapshot.data!);
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