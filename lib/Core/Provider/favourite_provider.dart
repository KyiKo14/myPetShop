// lib/Core/Provider/favourite_provider.dart  (REPLACE)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Model/item_model.dart';

class FavouriteNotifier extends StateNotifier<List<AppModel>> {
  FavouriteNotifier() : super([]);

  bool isFavourite(AppModel product) =>
      state.any((p) => p.image == product.image);

  void toggleFavourite(AppModel product) {
    if (isFavourite(product)) {
      state = state.where((p) => p.image != product.image).toList();
    } else {
      state = [...state, product];
    }
  }

  void clearAll() => state = [];
}

final favouriteProvider =
    StateNotifierProvider<FavouriteNotifier, List<AppModel>>(
  (ref) => FavouriteNotifier(),
);