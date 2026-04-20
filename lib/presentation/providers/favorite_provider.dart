import 'package:flutter/material.dart';
import '../../data/services/favorite_service.dart';
import '../../data/models/product_model.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  
  Set<int> _favoriteProductIds = {};
  List<ProductModel> _favoriteProducts = [];
  bool _isLoading = false;

  Set<int> get favoriteProductIds => _favoriteProductIds;
  List<ProductModel> get favoriteProducts => _favoriteProducts;
  bool get isLoading => _isLoading;

  // Check if product is favorite
  bool isFavorite(int productId) {
    return _favoriteProductIds.contains(productId);
  }

  // Load favorites from API
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final favorites = await _favoriteService.getFavorites();
      _favoriteProducts = favorites;
      _favoriteProductIds = favorites.map((p) => p.id).toSet();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(ProductModel product) async {
    final productId = product.id;
    final currentStatus = isFavorite(productId);
    
    // Optimistic update
    if (currentStatus) {
      _favoriteProductIds.remove(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
    } else {
      _favoriteProductIds.add(productId);
      _favoriteProducts.insert(0, product);
    }
    notifyListeners();

    try {
      final newStatus = await _favoriteService.toggleFavorite(
        productId,
        currentStatus,
      );
      
      // Update with actual status from server
      if (newStatus) {
        _favoriteProductIds.add(productId);
        // If it wasn't in the list yet (should have been via optimistic), add it
        if (!_favoriteProducts.any((p) => p.id == productId)) {
           _favoriteProducts.insert(0, product);
        }
      } else {
        _favoriteProductIds.remove(productId);
        _favoriteProducts.removeWhere((p) => p.id == productId);
      }
      notifyListeners();
      return newStatus;
    } catch (e) {
      // Revert on error
      if (currentStatus) {
        _favoriteProductIds.add(productId);
        _favoriteProducts.insert(0, product); // Re-insert at top
      } else {
        _favoriteProductIds.remove(productId);
        _favoriteProducts.removeWhere((p) => p.id == productId);
      }
      notifyListeners();
      return currentStatus;
    }
  }
}
