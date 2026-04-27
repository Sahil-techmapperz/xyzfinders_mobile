import '../../../core/config/api_service.dart';
import '../models/buyer_dashboard_stats.dart';

class BuyerService {
  final ApiService _apiService = ApiService();

  Future<BuyerDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/buyer/dashboard/stats');
      if (response.data['success'] == true) {
        return BuyerDashboardStats.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch dashboard stats');
    } catch (e) {
      rethrow;
    }
  }
}
