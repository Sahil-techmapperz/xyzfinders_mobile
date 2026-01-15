import 'package:flutter/material.dart';
import '../../data/services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  
  Set<int> _favoriteProductIds = {};
  bool _isLoading = false;

  Set<int> get favoriteProductIds => _favoriteProductIds;
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
      _favoriteProductIds = favorites.toSet();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int productId) async {
    final currentStatus = isFavorite(productId);
    
    // Optimistic update
    if (currentStatus) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();

    try {
      final newStatus = await _favoriteService.toggleFavorite(
        productId,
        currentStatus,
      );
      
      // Update with actual status
      if (newStatus) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
      notifyListeners();
      return newStatus;
    } catch (e) {
      // Revert on error
      if (currentStatus) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
      notifyListeners();
      rethrow;
    }
  }
}
