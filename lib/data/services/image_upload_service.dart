import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';

class ImageUploadService {
  final ApiService _apiService = ApiService();

  // Upload product image
  Future<Map<String, dynamic>> uploadProductImage({
    required int productId,
    required File imageFile,
  }) async {
    // Create form data
    final formData = FormData.fromMap({
      'product_id': productId,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _apiService.post(
      ApiConstants.uploadProductImages,
      data: formData,
    );

    return response.data['data'];
  }

  // Upload multiple product images
  Future<List<Map<String, dynamic>>> uploadMultipleProductImages({
    required int productId,
    required List<File> imageFiles,
  }) async {
    final List<Map<String, dynamic>> uploadedImages = [];

    for (final imageFile in imageFiles) {
      try {
        final result = await uploadProductImage(
          productId: productId,
          imageFile: imageFile,
        );
        uploadedImages.add(result);
      } catch (e) {
        // If one image fails, continue with others
        print('Failed to upload ${imageFile.path}: $e');
      }
    }

    return uploadedImages;
  }

  // Delete product image
  Future<void> deleteProductImage(int imageId) async {
    await _apiService.delete('${ApiConstants.uploadProductImages}/$imageId');
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      // Get filename properly for both platforms
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      print('Uploading with filename: $fileName');
      
      final response = await _apiService.post(
        '/upload/profile-image',
        data: formData,
      );

      return response.data['data'];
    } catch (e) {
      print('Upload error - Full details: $e');
      rethrow;
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    await _apiService.delete('/upload/profile-image');
  }

  // Get profile image URL for a user
  String getProfileImageUrl(int userId) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$baseUrl/api/images/user/$userId';
  }
}
