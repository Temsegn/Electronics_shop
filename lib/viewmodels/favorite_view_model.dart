import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:electronics_shop_app/models/product.dart';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final box = await Hive.openBox<Product>('favorites');
      state = box.values.toList();
    } catch (e) {
      // Handle error
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final box = await Hive.openBox<Product>('favorites');
      await box.clear();
      for (final product in state) {
        await box.add(product);
      }
    } catch (e) {
      // Handle error
      print('Error saving favorites: $e');
    }
  }

  void addToFavorites(Product product) {
    if (!state.any((p) => p.id == product.id)) {
      state = [...state, product];
      _saveFavorites();
    }
  }

  void removeFromFavorites(Product product) {
    state = state.where((p) => p.id != product.id).toList();
    _saveFavorites();
  }

  bool isFavorite(Product product) {
    return state.any((p) => p.id == product.id);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Product>>(
  (ref) => FavoritesNotifier(),
);