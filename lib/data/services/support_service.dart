import '../../../core/config/api_service.dart';

class SupportService {
  final ApiService _apiService = ApiService();

  // Get system settings (for contact info)
  Future<Map<String, dynamic>> getSupportSettings() async {
    final response = await _apiService.get('/settings');
    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return {};
  }

  // Get support categories (could include FAQs)
  Future<List<dynamic>> getSupportCategories() async {
    final response = await _apiService.get('/support/categories');
    if (response.data['success'] == true) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  }
}
