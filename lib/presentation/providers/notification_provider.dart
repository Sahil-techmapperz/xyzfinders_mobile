import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  NotificationSettingsModel? _settings;
  bool _isSettingsLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotificationSettingsModel? get settings => _settings;
  bool get isSettingsLoading => _isSettingsLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getNotifications();
      _notifications = result['notifications'];
      _unreadCount = result['unreadCount'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        // Update local state for performance
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          receiverId: _notifications[index].receiverId,
          senderId: _notifications[index].senderId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          link: _notifications[index].link,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          senderName: _notifications[index].senderName,
        );
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently or notify
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchSettings() async {
    _isSettingsLoading = true;
    notifyListeners();

    try {
      _settings = await _service.getSettings();
      _isSettingsLoading = false;
      notifyListeners();
    } catch (e) {
      _isSettingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    final oldSettings = _settings;
    _settings = newSettings;
    notifyListeners();

    try {
      await _service.updateSettings(newSettings);
    } catch (e) {
      _settings = oldSettings;
      notifyListeners();
      rethrow;
    }
  }
}
