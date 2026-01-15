import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/api_exception.dart';

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
        onError: (DioException error, handler) {
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
      throw _handleError(e);
    }
  }
  
  // Error handling
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timeout. Please try again.');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 
                        error.response?.data?['message'] ?? 
                        'An error occurred';
        
        switch (statusCode) {
          case 400:
            return ValidationException(
              message: message,
              data: error.response?.data,
            );
          case 401:
            return UnauthorizedException(message: message);
          case 404:
            return NotFoundException(message: message);
          case 500:
          case 502:
          case 503:
            return ServerException(message: message);
          default:
            return ApiException(
              message: message,
              statusCode: statusCode,
              data: error.response?.data,
            );
        }
        
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');
        
      case DioExceptionType.unknown:
      default:
        if (error.error.toString().contains('SocketException')) {
          return NetworkException();
        }
        return ApiException(message: 'An unexpected error occurred');
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
