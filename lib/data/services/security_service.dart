import '../../core/constants/api_constants.dart';
import '../../core/config/api_service.dart';
import '../../core/errors/api_exception.dart';

class SecurityService {
  final ApiService _apiService = ApiService();

  // Get active sessions
  Future<List<dynamic>> getActiveSessions() async {
    final response = await _apiService.get(ApiConstants.sessions);
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw ApiException(message: response.data['message'] ?? 'Failed to fetch sessions');
  }

  // Logout from all other devices
  Future<void> logoutAllOtherDevices() async {
    await _apiService.post(ApiConstants.logoutAllOtherDevices);
  }

  // Get login activity
  Future<List<dynamic>> getLoginActivity() async {
    final response = await _apiService.get(ApiConstants.loginActivity);
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw ApiException(message: response.data['message'] ?? 'Failed to fetch activity');
  }
}
