import '../../../core/config/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../models/buyer_dashboard_stats.dart';
import '../models/seller_model.dart';
import '../models/product_model.dart';

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

  Future<List<SellerModel>> getSellers({String search = '', int limit = 50}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.publicAgencies,
        queryParameters: {
          'search': search,
          'limit': limit,
        },
      );
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((e) => SellerModel.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch agencies');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSellerDetail(int id) async {
    try {
      final response = await _apiService.get(ApiConstants.publicAgencyById(id));
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'seller': SellerModel.fromJson(data['seller']),
          'products': (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList(),
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch agency details');
    } catch (e) {
      rethrow;
    }
  }
}
