import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/security_service.dart';
import '../../core/config/api_service.dart';
import '../../core/errors/api_exception.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _sessions = [];
  List<dynamic> _activity = [];
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get sessions => _sessions;
  List<dynamic> get activity => _activity;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  SecurityProvider() {
    _loadBiometricSetting();
    _checkBiometricAvailability();
  }

  // Check if biometric hardware and enrolled credentials exist
  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      _isBiometricAvailable = canCheck && isDeviceSupported;
      notifyListeners();
    } catch (e) {
      _isBiometricAvailable = false;
    }
  }

  // Load biometric setting from shared preferences
  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  // Toggle biometric setting — checks availability first
  Future<String?> toggleBiometric(bool value) async {
    if (value) {
      // Check hardware availability first
      if (!_isBiometricAvailable) {
        return 'Your device does not support biometric authentication (fingerprint or Face ID). Please ensure your device has biometric hardware and you have enrolled at least one biometric credential in your device settings.';
      }

      // Check if any biometrics are enrolled
      final LocalAuthentication auth = LocalAuthentication();
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return 'No biometrics enrolled on this device. Please set up a fingerprint or Face ID in your device settings first, then try again.';
      }

      // Before enabling, verify the user can actually authenticate
      final result = await authenticateWithBiometrics(
        reason: 'Please verify your identity to enable biometric login',
      );
      if (!result) {
        return 'Biometric verification failed. Please try again.';
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    _isBiometricEnabled = value;
    // If disabling biometric, wipe saved credentials from secure storage
    if (!value) {
      await ApiService().clearStoredCredentials();
    }
    notifyListeners();
    return null; // null = success
  }

  // Perform biometric authentication — returns true if successful
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern as fallback
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: ${e.message}');
      return false;
    }
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
