
import 'package:deponator_flutter/models/resource.dart';
import 'package:deponator_flutter/widgets/resource_grid_item.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ResourceGridScreen extends StatefulWidget {
  ResourceGridScreen({ 
    super.key,
    required this.items
  });
  List<Resource> items;

  @override
  State<ResourceGridScreen> createState() {
    return _ResourceGridState();
  }
}

class _ResourceGridState extends State<ResourceGridScreen> {
  late List<Resource> _filteredItems;
  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _selectResource(BuildContext context, Resource resource) async {
    setState(() {
      _filteredItems = _filteredItems
        .where((item) => item.name == 'item1')
        .toList();
    });
  }

  void _resetGrid() async {
    setState(() {
      _filteredItems = widget.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            children: [
              ElevatedButton(
                onPressed: _resetGrid, 
                child: const Text('return to dashboard')
              ),
              for (final item in _filteredItems)
                ResourceGridItem(
                  resource: item,
                  onSelectResource: () {
                    _selectResource(context, item);
                  },
              ),
            ]
      ),
    );
  }
}