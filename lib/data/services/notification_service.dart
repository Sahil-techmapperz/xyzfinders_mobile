import '../models/notification_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/api_service.dart';
import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio = ApiService().dio;

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/notifications');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<dynamic> list = data['notifications'];
        final notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
        final unreadCount = data['unreadCount'] as int;
        return {
          'notifications': notifications,
          'unreadCount': unreadCount,
        };
      }
      throw Exception('Failed to load notifications');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.put('${ApiConstants.baseUrl}/notifications/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/notifications/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationSettingsModel> getSettings() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/notifications/settings');
      if (response.statusCode == 200) {
        return NotificationSettingsModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load settings');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      await _dio.put(
        '${ApiConstants.baseUrl}/notifications/settings',
        data: settings.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
