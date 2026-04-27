import '../models/job_application_model.dart';
import '../../core/config/api_service.dart';

class JobApplicationService {
  final ApiService _apiService = ApiService();

  Future<List<JobApplicationModel>> getMyApplications() async {
    try {
      final response = await _apiService.get('/jobs/applicants?role=buyer');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => JobApplicationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getApplicantsForMyJobs({int? jobId}) async {
    try {
      String path = '/jobs/applicants?role=seller';
      if (jobId != null) {
        path += '&job_id=$jobId';
      }
      
      final response = await _apiService.get(path);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> applicantsJson = data['applicants'];
        final List<dynamic> jobsJson = data['jobs'];
        
        return {
          'applicants': applicantsJson.map((e) => JobApplicationModel.fromJson(e)).toList(),
          'jobs': jobsJson.map((e) => SellerJobPostModel.fromJson(e)).toList(),
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch applicants');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateApplicationStatus(int applicationId, String status) async {
    try {
      final response = await _apiService.patch(
        '/jobs/applicants',
        data: {
          'application_id': applicationId,
          'status': status,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
