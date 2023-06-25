import 'package:deponator_flutter/models/resource.dart';
import 'package:flutter/material.dart';

class ResourceGridItem extends StatelessWidget {
  const ResourceGridItem({
    super.key, 
    required this.resource,
    required this.onSelectResource,
    // required this.showBackButton
  });

  final Resource resource;
  final void Function() onSelectResource;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectResource,
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.55),
              Theme.of(context).secondaryHeaderColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          )
        ),
        child: Text(
          resource.name,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          )
        )
      ),
    );
  }
}