import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../../core/utils/device_util.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'user_type': role,
        ...await DeviceUtil.getDeviceInfo(),
      },
    );

    final responseData = response.data;
    if (responseData is! Map || responseData['data'] is! Map) {
      throw ApiException(message: 'Unexpected response format from server');
    }

    final data = responseData['data'];
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;

    // Save token and user data
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
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        ...await DeviceUtil.getDeviceInfo(),
      },
    );

    final responseData = response.data;
    if (responseData is! Map || responseData['data'] is! Map) {
      throw ApiException(message: 'Unexpected response format from server');
    }

    final data = responseData['data'];
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;

    // Save token and user data
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
  }

  // Google Login
  Future<Map<String, dynamic>> googleLogin(String accessToken) async {
    final response = await _apiService.post(
      '/auth/google/callback', // Adjust endpoint according to your backend config
      data: {
        'access_token': accessToken,
      },
    );

    final responseData = response.data;
    if (responseData is! Map || responseData['data'] is! Map) {
      throw ApiException(message: 'Unexpected response format from server');
    }

    final data = responseData['data'];
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;

    // Save token and user data
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
  }

  // Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    final response = await _apiService.get(ApiConstants.me);
    final data = response.data['data'];
    return UserModel.fromJson(data);
  }

  // Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? avatar,
    String? location,
    String? address,
  }) async {
    final response = await _apiService.put(
      ApiConstants.userProfile,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (location != null) 'location': location,
        if (address != null) 'address': address,
      },
    );
    final data = response.data['data'];
    return UserModel.fromJson(data);
  }

  // Upload profile image
  Future<void> uploadProfileImage(File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    await _apiService.post(
      ApiConstants.uploadProfileImage,
      data: formData,
    );
  }

  // Switch mode (buyer/seller)
  Future<UserModel> switchMode(String mode) async {
    final response = await _apiService.post(
      ApiConstants.switchMode,
      data: {'mode': mode},
    );
    final data = response.data['data'];
    final user = UserModel.fromJson(data);
    
    // Update local user data
    await _apiService.saveUserData(
      userId: user.id,
      email: user.email,
      role: user.role,
    );
    
    return user;
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearUserData();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _apiService.isLoggedIn();
  }

  // Verify email
  Future<void> verifyEmail({
    required String token,
  }) async {
    await _apiService.post(
      ApiConstants.verifyEmail,
      data: {'token': token},
    );
  }

  // Resend verification email
  Future<void> resendVerification({
    required String email,
  }) async {
    await _apiService.post(
      ApiConstants.resendVerification,
      data: {'email': email},
    );
  }

  // Forgot password
  Future<void> forgotPassword({
    required String email,
  }) async {
    await _apiService.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiService.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.post(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  // Delete account
  Future<void> deleteAccount() async {
    await _apiService.delete(ApiConstants.deleteAccount);
    await _apiService.clearUserData();
  }

  // Refresh token
  Future<String> refreshToken() async {
    final response = await _apiService.post(ApiConstants.refreshToken);
    final token = response.data['data']['token'] as String;
    await _apiService.setAuthToken(token);
    return token;
  }
}
