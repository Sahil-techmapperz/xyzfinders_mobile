import '../models/user_model.dart';
import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';

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
        'user_type': role,  // Backend expects 'user_type' not 'role'
      },
    );

    final data = response.data['data'];
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
      },
    );

    final data = response.data['data'];
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

  // Refresh token
  Future<String> refreshToken() async {
    final response = await _apiService.post(ApiConstants.refreshToken);
    final token = response.data['data']['token'] as String;
    await _apiService.setAuthToken(token);
    return token;
  }
}
