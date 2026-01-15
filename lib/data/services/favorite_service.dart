import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  // Get user's favorite products
  Future<List<int>> getFavorites() async {
    try {
      final response = await _apiService.get(ApiConstants.favorites);
      final data = response.data['data'] as List;
      return data.map((item) => item['product_id'] as int).toList();
    } catch (e) {
      return [];
    }
  }

  // Add product to favorites
  Future<void> addToFavorites(int productId) async {
    await _apiService.post(
      ApiConstants.favorites,
      data: {'product_id': productId},
    );
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(int productId) async {
    await _apiService.delete('${ApiConstants.favorites}/$productId');
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int productId, bool currentStatus) async {
    if (currentStatus) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }
}
