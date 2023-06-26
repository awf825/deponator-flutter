import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deponator_flutter/models/resource.dart';

class GridDataNotifier extends StateNotifier<List<Resource>> {
  GridDataNotifier() : super([]);

  setGridData(data) {
    state = data;
  }
}

final gridDataProvider = StateNotifierProvider<GridDataNotifier, List<Resource>>((ref) {
  return GridDataNotifier();
});