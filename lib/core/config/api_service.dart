import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/api_exception.dart';
import '../../main.dart';
import '../../presentation/screens/home/home_screen.dart';

import '../../presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = await getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          
          if (statusCode == 401) {
            // Handle session expiration
            debugPrint('[SESSION EXPIRED] 401 Unauthorized detected');
            
            // Only attempt logout and redirect if we actually had a token
            final currentToken = await getAuthToken();
            if (currentToken != null) {
              await clearAuthToken(); // Immediately clear to prevent loops
              
              // Access AuthProvider through navigatorKey's context to reset state reactively
              if (MyApp.navigatorKey.currentContext != null) {
                try {
                  // Use listen: false because we are in an interceptor
                  final authProvider = Provider.of<AuthProvider>(MyApp.navigatorKey.currentContext!, listen: false);
                  
                  if (authProvider.isAuthenticated) {
                    await authProvider.logout();
                    
                    // Redirect to home
                    MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  debugPrint('[AUTH ERROR] Failed to logout via provider: $e');
                  // Fallback to direct clearing if provider fails
                  await clearUserData();
                  if (MyApp.navigatorKey.currentState != null) {
                    MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                }
              } else {
                // Fallback if context is not available
                await clearUserData();
              }
            }
          }

          final exception = _handleError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              type: error.type,
            ),
          );
        },
      ),
    );
  }
  
  // Get singleton Dio instance
  Dio get dio => _dio;
  
  // Auth token management
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }
  
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }
  
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
  }
  
  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw _handleError(e);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw _handleError(e);
    }
  }
  
  // Error handling
  ApiException _handleError(DioException error) {
    final path = error.requestOptions.path;
    final statusCode = error.response?.statusCode;
    
    debugPrint('[API ERROR] Path: $path, Status: $statusCode, Type: ${error.type}');

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(message: 'Cannot reach server. Please check your internet.');
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timeout. Please try again.');
        
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        String message = 'An error occurred';
        
        if (data is Map) {
          message = data['error'] ?? data['message'] ?? message;
        } else if (data is String && data.isNotEmpty) {
          // Handle cases where server returns a plain string or HTML
          if (data.contains('<!DOCTYPE html>') || data.contains('<html>')) {
            message = 'Server returned an HTML error (likely 404 or 500).';
          } else {
            message = data;
          }
        }
        
        debugPrint('[API BAD RESPONSE] Data: $data');
        
        switch (statusCode) {
          case 400:
            return ValidationException(
              message: message,
              data: data is Map ? data : null,
            );
          case 401:
            return UnauthorizedException(message: message);
          case 403:
            return ApiException(message: message); // Forbidden
          case 404:
            return NotFoundException(message: message);
          case 500:
          case 502:
          case 503:
            return ServerException(message: message);
          default:
            return ApiException(message: message);
        }
        
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled');
        
      default:
        // Log the actual error for debugging
        final dynamic originalError = error.error;
        debugPrint('[DIO UNKNOWN ERROR]: $originalError');
        
        String errorMessage = 'Network connection issue';
        if (originalError != null) {
          errorMessage += ': $originalError';
        }
        
        return ApiException(message: errorMessage);
    }
  }
  
  // Userアクセスpreferencesへの保存
  Future<void> saveUserData({
    required int userId,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.userEmailKey, email);
    await prefs.setString(AppConstants.userRoleKey, role);
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }
  
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await clearAuthToken();
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }
}
