import '../../../core/config/api_service.dart';
import '../models/seller_dashboard_stats.dart';

class SellerService {
  final ApiService _apiService = ApiService();

  Future<SellerDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/seller/dashboard/stats');
      if (response.data['success'] == true) {
        return SellerDashboardStats.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch dashboard stats');
    } catch (e) {
      rethrow;
    }
  }
}
