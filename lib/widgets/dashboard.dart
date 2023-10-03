import 'package:deponator_flutter/providers/grid_data_provider.dart';
import 'package:deponator_flutter/services/data_service.dart';
import 'package:deponator_flutter/widgets/resource_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:deponator_flutter/services/auth_service.dart';
import 'package:deponator_flutter/widgets/new_resource.dart';
import 'package:deponator_flutter/models/resource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({ super.key });

  @override
  ConsumerState<Dashboard> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends ConsumerState<Dashboard> {
  final List<Resource> _resources = [];
  // use loadedItems as a reference to reset to 
  final List<Resource> loadedItems = [];
  final _authService = AuthService();
  final _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _resetGrid() async {
    ref.read(gridDataProvider.notifier).setGridData(loadedItems);
  }

  Future<void> _loadItems() async {
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
    ref.read(gridDataProvider.notifier).setGridData(loadedItems);
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
    final gridDataItems = ref.watch(gridDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cases'),
        actions: [
          ElevatedButton(
            onPressed: _resetGrid, 
            child: const Text('Return to dashboard')
          ),
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
      body: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          for (final item in gridDataItems)
            ResourceGridItem(
              resource: item,
              onSelectResource: () {
                ref.read(gridDataProvider.notifier).setGridData(gridDataItems.where((item) => item.name == 'item1').toList());
              }
          ),
        ]
      ),
      // body: DraggableGridViewBuilder(
      //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 2, 
      //     childAspectRatio: 3 / 2,
      //     crossAxisSpacing: 20,
      //     mainAxisSpacing: 20,
      //   ),
      //   children: <DraggableGridItem>[
      //     for (final item in gridDataItems)
      //       DraggableGridItem(
      //         child: ResourceGridItem(
      //           resource: item,
      //           onSelectResource: () {
      //             ref.read(gridDataProvider.notifier).setGridData(gridDataItems.where((item) => item.name == 'item1').toList());
      //           }
      //         ),
      //       )
      //   ],
      //   dragCompletion: (List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
      //     print( 'onDragAccept: $beforeIndex -> $afterIndex');
      //   },

      // )
    );
  }
}
// flutter pub add flutter_draggable_gridview

// DraggableGridViewBuilder(
/*
          This property contains bool value. If this property is false then it works with simple press draggable or 
          else it works with long press. default value is 'true'.
 */         
//         isOnlyLongPress: false, ?

/*
          With this callback, you have to return a Widget and we will use this widget in feedback. 
          (feedback -> The widget to show under the pointer when a drag is under way)
          
*/
//         dragFeedback: (List<DraggableGridItem> list, int index) {
//           return Container(
//             child: list[index].child,
//             width: 200,
//             height: 150,
//           );
//         },

/*
          With this callback, you have to return a PlaceHolderWidget and we will use this widget in place holder.
*/
//         dragPlaceHolder: (List<DraggableGridItem> list, int index) {
//           return PlaceHolderWidget(
//             child: Container(
//               color: Colors.white,
//             ),
//           );
//         },
//       );

/*
          With this callback, you have to return a Widget and we will display this widget instead of child when drags are under way
*/
//         dragChildWhenDragging: (List<DraggableGridItem> list, int index) {
//           return PlaceHolderWidget(
//             child: Container(
//               color: Colors.white,
//             ),
//           );
//         },
//       );

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
//