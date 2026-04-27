import 'package:flutter/material.dart';
import '../../data/models/job_application_model.dart';
import '../../data/services/job_application_service.dart';

class JobApplicationProvider with ChangeNotifier {
  final JobApplicationService _service = JobApplicationService();
  
  List<JobApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _error;

  List<JobApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _service.getMyApplications();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
