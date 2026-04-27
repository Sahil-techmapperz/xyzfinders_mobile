import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/errors/api_exception.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String _currentMode = 'buyer';
  int _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get lastUpdateTimestamp => _lastUpdateTimestamp;
  String get currentMode {
    if (_user != null) return _user!.currentMode;
    return _currentMode;
  }
  bool get isAuthenticated => _user != null;
  bool get isSellerMode => currentMode == 'seller';

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Login
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '817332061056-31hf6099bslbt4r0j8rnrm3l5m43fejn.apps.googleusercontent.com',
      );

      print("DEBUG: GoogleSignIn starting...");
      await googleSignIn.signOut(); // Force clear previous session so popup always shows
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print("DEBUG: GoogleSignIn returned: ${googleUser?.email}");
      
      if (googleUser == null) {
        // User canceled the sign-in flow OR Google rejected the SHA-1 fingerprint silently
        _error = 'Google Sign-In canceled or SHA-1 configuration missing/mismatch in Google Console.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        throw Exception('Failed to retrieve access token from Google');
      }

      final result = await _authService.googleLogin(accessToken);
      print("DEBUG: Backend returned successfully: $result");
      
      _user = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to sign in with Google: $e';
      print("DEBUG: Google Login Exception: $_error");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get current user
  Future<void> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      _currentMode = _user?.currentMode ?? 'buyer';
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        await logout();
      }
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatar,
    String? location,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        avatar: avatar,
        location: location,
        address: address,
      );
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload Avatar
  Future<bool> uploadAvatar(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.uploadProfileImage(file);
      _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to upload profile image';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to change password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _user = null;
      _currentMode = 'buyer';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete account';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    _currentMode = 'buyer';
    notifyListeners();
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await getCurrentUser();
    } else {
      _currentMode = 'buyer';
    }
  }

  // Toggle mode
  Future<bool> toggleMode() async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMode = isSellerMode ? 'buyer' : 'seller';
      _user = await _authService.switchMode(newMode);
      _currentMode = _user!.currentMode;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('[AUTH PROVIDER ERROR]: ${e.message}');
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      debugPrint('[AUTH PROVIDER UNKNOWN ERROR]: $e');
      debugPrint('$stack');
      _error = 'Failed to switch mode';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh current user data
  Future<void> refreshUser() async {
    if (_user == null) return;
    
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Silently fail, user data will update on next login
      print('Failed to refresh user: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
