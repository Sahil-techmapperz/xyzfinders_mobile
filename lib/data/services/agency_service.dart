import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agency_models.dart';
import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';

class AgencyService {
  final ApiService _apiService = ApiService();

  // Login for agency
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.agencyLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final responseData = response.data;
    if (responseData['success'] == true) {
      final data = responseData['data'];
      final user = AgencyUser.fromJson(data['user']);
      final token = data['token'] as String;

      // Save token and user data
      await _apiService.setAuthToken(token);
      await _apiService.saveUserData(
        userId: user.id,
        email: user.email,
        role: user.role,
      );
      // Mark this session as an agency session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isAgencyKey, true);

      return {
        'user': user,
        'token': token,
      };
    } else {
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  }

  // Register new agency
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    // If data contains files (XFile), convert to FormData
    dynamic requestData;
    
    if (data.values.any((v) => v is String && v.startsWith('FILE:'))) {
      // This is a simplified logic, I'll check for actual file types in the screen
    }

    // Actual implementation for the screen will pass a Map with XFile or MultipartFile
    final formData = FormData.fromMap(data);

    final response = await _apiService.post(
      ApiConstants.agencyRegister,
      data: formData,
    );

    final responseData = response.data;
    if (responseData['success'] == true) {
      final data = responseData['data'];
      final user = AgencyUser.fromJson(data['user']);
      final token = data['token'] as String;

      await _apiService.setAuthToken(token);
      await _apiService.saveUserData(
        userId: user.id,
        email: user.email,
        role: user.role,
      );

      return {
        'user': user,
        'token': token,
      };
    } else {
      throw Exception(responseData['message'] ?? 'Registration failed');
    }
  }

  // Get dashboard stats
  Future<AgencyDashboardStats> getDashboard() async {
    final response = await _apiService.get(ApiConstants.agencyDashboard);
    if (response.data['success'] == true) {
      return AgencyDashboardStats.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load dashboard');
    }
  }

  // Get agency profile
  Future<AgencyProfile> getProfile() async {
    final response = await _apiService.get(ApiConstants.agencyProfile);
    if (response.data['success'] == true) {
      return AgencyProfile.fromJson(response.data['data']['agency']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load profile');
    }
  }

  // Update profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    // Convert to FormData if files are present
    dynamic requestData = data;
    if (data.values.any((v) => v is MultipartFile)) {
      requestData = FormData.fromMap(data);
    }

    final response = await _apiService.patch(
      ApiConstants.agencyProfile,
      data: requestData,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update profile');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.post(
      ApiConstants.agencyChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to change password');
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    final response = await _apiService.post(
      ApiConstants.agencyForgotPassword,
      data: {'email': email},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to send reset code');
    }
  }

  // Reset password
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final response = await _apiService.post(
      ApiConstants.agencyResetPassword,
      data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to reset password');
    }
  }

  // Get agency ads
  Future<List<AgencyAd>> getAds() async {
    final response = await _apiService.get(ApiConstants.agencyAds);
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((e) => AgencyAd.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load ads');
    }
  }

  // Post new ad
  Future<void> postAd(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    final response = await _apiService.post(
      ApiConstants.agencyAds,
      data: formData,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to post ad');
    }
  }

  // Update ad status
  Future<void> updateAdStatus(int adId, String status) async {
    final response = await _apiService.patch(
      '${ApiConstants.agencyAds}/$adId',
      data: {'status': status},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update status');
    }
  }

  // Delete ad
  Future<void> deleteAd(int adId) async {
    final response = await _apiService.delete('${ApiConstants.agencyAds}/$adId');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete ad');
    }
  }

  // Update ad (edit)
  Future<void> updateAd(int adId, Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    final response = await _apiService.patch(
      '${ApiConstants.agencyAds}/$adId',
      data: formData,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update ad');
    }
  }

  // Get ad analytics
  Future<AgencyDashboardStats> getAdAnalytics(int adId) async {
    final response = await _apiService.get('${ApiConstants.agencyAds}/$adId/analytics');
    if (response.data['success'] == true) {
      return AgencyDashboardStats.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load ad analytics');
    }
  }

  // Get leads
  Future<List<AgencyLead>> getLeads() async {
    final response = await _apiService.get(ApiConstants.agencyLeads);
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((e) => AgencyLead.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load leads');
    }
  }

  // Update lead status
  Future<void> updateLeadStatus(int leadId, String status) async {
    final response = await _apiService.patch(
      ApiConstants.agencyLeadStatus(leadId),
      data: {'status': status},
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update lead status');
    }
  }

  // Get agents
  Future<List<AgencyAgent>> getAgents() async {
    final response = await _apiService.get(ApiConstants.agencyAgents);
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((e) => AgencyAgent.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load agents');
    }
  }

  // Add agent
  Future<void> addAgent(Map<String, dynamic> data) async {
    final response = await _apiService.post(
      ApiConstants.agencyAgents,
      data: data,
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to add agent');
    }
  }

  // Delete agent
  Future<void> deleteAgent(int agentId) async {
    final response = await _apiService.delete(ApiConstants.agencyDeleteAgent(agentId));
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete agent');
    }
  }

  // Support
  Future<List<AgencySupportTicket>> getSupportTickets() async {
    final response = await _apiService.get(ApiConstants.agencySupport);
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((e) => AgencySupportTicket.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load support tickets');
    }
  }

  Future<void> createSupportTicket(String title, String description) async {
    final response = await _apiService.post(
      ApiConstants.agencySupport,
      data: {
        'title': title,
        'description': description,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to create ticket');
    }
  }
}
