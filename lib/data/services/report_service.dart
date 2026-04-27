import '../../../core/config/api_service.dart';
import '../models/report_model.dart';
import '../models/chat_model.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<List<ReportModel>> getSellerReports() async {
    try {
      final response = await _apiService.get('/seller/reports');
      final responseData = response.data;
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      throw Exception(responseData['message'] ?? 'Failed to fetch reports');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatMessage>> getReportMessages(int reportId) async {
    try {
      final response = await _apiService.get('/reports/$reportId/messages');
      final responseData = response.data;
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      throw Exception(responseData['message'] ?? 'Failed to fetch messages');
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatMessage> sendReportMessage(int reportId, String message) async {
    try {
      final response = await _apiService.post(
        '/reports/$reportId/messages',
        data: {'message': message},
      );
      final responseData = response.data;
      if (responseData['success'] == true) {
        return ChatMessage.fromJson(responseData['data']);
      }
      throw Exception(responseData['message'] ?? 'Failed to send message');
    } catch (e) {
      rethrow;
    }
  }
}
