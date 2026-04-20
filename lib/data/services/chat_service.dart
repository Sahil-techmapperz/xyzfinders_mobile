import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/chat_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<List<Conversation>> getConversations() async {
    final response = await _apiService.get('/messages/conversations');
    final data = response.data['data'] as List;
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  Future<List<ChatMessage>> getMessages({required String entityId, int? productId}) async {
    final pathId = productId == null ? 'null' : productId.toString();
    final response = await _apiService.get('/messages/$pathId/$entityId');
    final data = response.data['data'] as List;
    return data.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<ChatMessage> sendMessage({
    int? productId,
    String? receiverId,
    String? receiverAgencyId,
    String? message,
    String? attachmentUrl,
  }) async {
    final response = await _apiService.post(
      '/messages',
      data: {
        'product_id': productId,
        'receiver_id': receiverId,
        'receiver_agency_id': receiverAgencyId,
        'message': message ?? '',
        'attachment_url': attachmentUrl,
      },
    );
    return ChatMessage.fromJson(response.data['data']);
  }

  Future<String?> uploadChatAttachment(File file) async {
    try {
      // 1. Get Auth Params from backend
      final authRes = await _apiService.get('/auth/imagekit');
      if (authRes.statusCode != 200) return null;

      final authData = authRes.data;
      final String token = authData['token'];
      final String signature = authData['signature'];
      final int expire = authData['expire'];
      final String publicKey = authData['publicKey'];

      // 2. Upload to ImageKit
      final fileName = file.path.split(Platform.pathSeparator).last;
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'fileName': fileName,
        'token': token,
        'signature': signature,
        'expire': expire,
        'publicKey': publicKey,
        'useUniqueFileName': 'true',
        'folder': '/chat_attachments',
      });

      final uploadRes = await dio.post(
        'https://upload.imagekit.io/api/v1/files/upload',
        data: formData,
      );

      if (uploadRes.statusCode == 200) {
        return uploadRes.data['url'];
      }
    } catch (e) {
      print('Error uploading chat attachment to ImageKit: $e');
    }
    return null;
  }
}
