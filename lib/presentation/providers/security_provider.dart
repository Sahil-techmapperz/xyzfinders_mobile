import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/security_service.dart';
import '../../core/errors/api_exception.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  
  bool _isLoading = false;
  String? _error;
  List<dynamic> _sessions = [];
  List<dynamic> _activity = [];
  bool _isBiometricEnabled = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get sessions => _sessions;
  List<dynamic> get activity => _activity;
  bool get isBiometricEnabled => _isBiometricEnabled;

  SecurityProvider() {
    _loadBiometricSetting();
  }

  // Load biometric setting from shared preferences
  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  // Toggle biometric setting
  Future<void> toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    _isBiometricEnabled = value;
    notifyListeners();
  }

  // Fetch active sessions
  Future<void> fetchSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _securityService.getActiveSessions();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout all other devices
  Future<bool> logoutAllOtherDevices() async {
    try {
      await _securityService.logoutAllOtherDevices();
      // Remove all except current
      _sessions.removeWhere((s) => s['isCurrent'] != true);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fetch login activity
  Future<void> fetchActivity() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activity = await _securityService.getLoginActivity();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }
}
