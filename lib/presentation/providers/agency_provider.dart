import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/agency_models.dart';
import '../../data/services/agency_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/api_exception.dart';

class AgencyProvider with ChangeNotifier {
  final AgencyService _agencyService = AgencyService();

  AgencyUser? _agencyUser;
  AgencyDashboardStats? _stats;
  List<AgencyLead> _leads = [];
  List<AgencyAgent> _agents = [];
  List<AgencyAd> _ads = [];
  List<AgencySupportTicket> _tickets = [];
  AgencyProfile? _profile;

  bool _isLoading = false;
  String? _error;
  bool _isAwaitingApproval = false;

  AgencyUser? get agencyUser => _agencyUser;
  AgencyDashboardStats? get stats => _stats;
  List<AgencyLead> get leads => _leads;
  List<AgencyAgent> get agents => _agents;
  List<AgencyAd> get ads => _ads;
  List<AgencySupportTicket> get tickets => _tickets;
  AgencyProfile? get profile => _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAwaitingApproval => _isAwaitingApproval;
  bool get isAuthenticated => _agencyUser != null;

  // Restore agency session on app startup
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAgency = prefs.getBool(AppConstants.isAgencyKey) ?? false;
      if (!isAgency) return;

      // Try fetching profile — if token is valid, mark as authenticated
      final profile = await _agencyService.getProfile();
      _profile = profile;
      // Reconstruct a minimal AgencyUser from profile so isAuthenticated == true
      _agencyUser = AgencyUser(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        agencyName: profile.agencyName,
        role: 'owner',
        isVerified: profile.isVerified,
        phone: profile.phone,
        location: profile.location,
        isAgency: true,
      );
      notifyListeners();
    } catch (_) {
      // Token expired or invalid — clear agency flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.isAgencyKey);
      _agencyUser = null;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    _isAwaitingApproval = false;
    notifyListeners();

    try {
      final result = await _agencyService.login(email: email, password: password);
      _agencyUser = result['user'] as AgencyUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('403') || e.toString().toLowerCase().contains('approval')) {
        _isAwaitingApproval = true;
        _error = 'Your agency account is awaiting admin approval.';
      } else {
        _error = e.toString().replaceAll('Exception: ', '');
      }
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _agencyService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _agencyService.resetPassword(email, otp, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _agencyService.register(data);
      _agencyUser = result['user'] as AgencyUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Dashboard
  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _agencyService.getDashboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _agencyService.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leads
  Future<void> fetchLeads() async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _agencyService.getLeads();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLeadStatus(int leadId, String status) async {
    try {
      await _agencyService.updateLeadStatus(leadId, status);
      await fetchLeads();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Agents
  Future<void> fetchAgents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _agents = await _agencyService.getAgents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAgent(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _agencyService.addAgent(data);
      await fetchAgents();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAgent(int agentId) async {
    try {
      await _agencyService.deleteAgent(agentId);
      await fetchAgents();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Ads
  Future<void> fetchAds() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ads = await _agencyService.getAds();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<AgencyDashboardStats?> fetchAdAnalytics(int adId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final stats = await _agencyService.getAdAnalytics(adId);
      _isLoading = false;
      notifyListeners();
      return stats;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> postAd(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _agencyService.postAd(data);
      await fetchAds();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAdStatus(int adId, String status) async {
    try {
      await _agencyService.updateAdStatus(adId, status);
      await fetchAds();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAd(int adId) async {
    try {
      await _agencyService.deleteAd(adId);
      await fetchAds();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAd(int adId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _agencyService.updateAd(adId, data);
      await fetchAds();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Support
  Future<void> fetchTickets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tickets = await _agencyService.getSupportTickets();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket(String title, String description) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _agencyService.createSupportTicket(title, description);
      await fetchTickets();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() async {
    _agencyUser = null;
    _stats = null;
    _leads = [];
    _agents = [];
    _ads = [];
    _tickets = [];
    _profile = null;
    // Clear agency session flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.isAgencyKey);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
