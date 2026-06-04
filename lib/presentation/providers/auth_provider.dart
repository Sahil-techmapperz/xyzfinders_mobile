import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/errors/api_exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
        clientId: Platform.isIOS ? '630795865988-36cm6b1plso307th6l235744vqlvd0eb.apps.googleusercontent.com' : null,
        scopes: ['email', 'profile'],
        serverClientId: '630795865988-uff05ra880vp3s66cpmsj31satg1i15t.apps.googleusercontent.com',
      );

      print("DEBUG: GoogleSignIn starting...");
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut(); // Force clear previous session so popup always shows
      }
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
      final String? idToken = googleAuth.idToken;

      if (accessToken == null && idToken == null) {
        throw Exception('Failed to retrieve tokens from Google');
      }

      final result = await _authService.googleLogin(
        accessToken: accessToken,
        idToken: idToken,
      );
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

  // Apple Login
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to retrieve identity token from Apple');
      }

      String? userJson;
      if (credential.givenName != null || credential.familyName != null) {
        userJson = jsonEncode({
          'name': {
            'firstName': credential.givenName ?? '',
            'lastName': credential.familyName ?? '',
          }
        });
      }

      final result = await _authService.appleLogin(
        idToken: idToken,
        userJson: userJson,
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
      _error = 'Failed to sign in with Apple: $e';
      print("DEBUG: Apple Login Exception: $_error");
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
      final currentModeBefore = currentMode;
      _user = updatedUser.copyWith(currentMode: currentModeBefore);
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
      await refreshUser(); // Refresh the user object to load the new ImageKit avatar URL
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

  // Forgot Password
  Future<void> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      throw e;
    } catch (e) {
      _error = 'Failed to send forgot password email';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
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

  // Biometric Login — replays securely stored credentials after biometric passes
  Future<bool> loginWithBiometric() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.loginWithBiometric();
      _user = result['user'] as UserModel;
      _currentMode = _user?.currentMode ?? 'buyer';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Biometric login failed. Please log in with your password.';
      _isLoading = false;
      notifyListeners();
      return false;
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
      final currentModeBefore = currentMode;
      _user = await _authService.getCurrentUser();
      _user = _user?.copyWith(currentMode: currentModeBefore);
      notifyListeners();
    } catch (e) {
      // Silently fail, user data will update on next login
      print('Failed to refresh user: $e');
    }
  }

  // Update Resume URL
  Future<bool> updateResumeUrl(String resumeUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateResumeUrl(resumeUrl);
      await refreshUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update CV';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add a new resume
  Future<bool> addResume(String name, String url) async {
    if (_user == null) return false;
    final resumes = List<ResumeModel>.from(_user!.resumes);
    final isFirst = resumes.isEmpty;
    
    final newResume = ResumeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
      isDefault: isFirst,
    );
    
    resumes.add(newResume);
    return await updateResumeUrl(json.encode(resumes.map((r) => r.toJson()).toList()));
  }

  // Remove a resume
  Future<bool> removeResume(String id) async {
    if (_user == null) return false;
    final resumes = List<ResumeModel>.from(_user!.resumes);
    final wasDefault = resumes.any((r) => r.id == id && r.isDefault);
    resumes.removeWhere((r) => r.id == id);
    
    if (wasDefault && resumes.isNotEmpty) {
      final first = resumes[0];
      resumes[0] = ResumeModel(
        id: first.id,
        name: first.name,
        url: first.url,
        isDefault: true,
      );
    }
    
    final newVal = resumes.isEmpty ? '' : json.encode(resumes.map((r) => r.toJson()).toList());
    return await updateResumeUrl(newVal);
  }

  // Set default resume
  Future<bool> setDefaultResume(String id) async {
    if (_user == null) return false;
    final resumes = _user!.resumes.map((r) {
      return ResumeModel(
        id: r.id,
        name: r.name,
        url: r.url,
        isDefault: r.id == id,
      );
    }).toList();
    
    return await updateResumeUrl(json.encode(resumes.map((r) => r.toJson()).toList()));
  }

  // Delete Resume (Legacy support)
  Future<bool> deleteResume() async {
    return await updateResumeUrl('');
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
