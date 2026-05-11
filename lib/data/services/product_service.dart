import 'dart:io';
import '../../core/config/api_service.dart';
import '../models/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int? perPage,
    int? categoryId,
    int? locationId,
    String? locationSearch,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sortBy,
    bool? verifiedOnly,
    // Automobile filters
    String? make,
    String? model,
    String? year,
    String? km,
    String? fuel,
    String? transmission,
    // Job filters
    String? jobType,
    String? experience,
    double? minSalary,
    String? workMode,
    // Real Estate filters
    String? bedroom,
    String? purpose,
    // Mobile filters
    String? brand,
    String? storage,
    String? ram,
    String? type,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      if (perPage != null) 'per_page': perPage,
      if (categoryId != null) 'category_id': categoryId,
      if (locationId != null) 'location_id': locationId,
      if (locationSearch != null && locationSearch.isNotEmpty) 'location_search': locationSearch,
      if (condition != null) 'condition': condition,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (search != null) 'search': search,
      if (sortBy != null) 'sort_by': sortBy,
      if (verifiedOnly != null) 'verified_only': verifiedOnly,
      // Automobile
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (km != null) 'km': km,
      if (fuel != null) 'fuel': fuel,
      if (transmission != null) 'transmission': transmission,
      // Jobs
      if (jobType != null) 'job_type': jobType,
      if (experience != null) 'experience': experience,
      if (minSalary != null) 'min_salary': minSalary,
      if (workMode != null) 'work_mode': workMode,
      // Real Estate
      if (bedroom != null) 'bedroom': bedroom,
      if (purpose != null) 'purpose': purpose,
      // Mobiles
      if (brand != null) 'brand': brand,
      if (storage != null) 'storage': storage,
      if (ram != null) 'ram': ram,
      if (type != null) 'type': type,
    };

    final response = await _apiService.get('/products', queryParameters: queryParams);
    
    final data = response.data['data'];
    List<dynamic> productsJson = [];
    Map<String, dynamic> pagination = {'current_page': 1, 'total_pages': 1};

    if (data is List) {
      productsJson = data;
    } else if (data is Map) {
      productsJson = data['products'] ?? [];
      pagination = data['pagination'] ?? pagination;
    }
    
    final List<ProductModel> products = productsJson.map((json) => ProductModel.fromJson(json)).toList();
    
    return {
      'products': products,
      'pagination': pagination,
    };
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _apiService.get('/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    double? originalPrice,
    required int categoryId,
    required int locationId,
    required String condition,
  }) async {
    final response = await _apiService.post('/seller/products/create', data: {
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'category_id': categoryId,
      'location_id': locationId,
      'condition': condition,
    });
    return ProductModel.fromJson(response.data['data']);
  }

  // Get ImageKit Auth Parameters
  Future<Map<String, dynamic>> getImageKitAuth() async {
    final response = await _apiService.get('/auth/imagekit');
    return response.data;
  }

  // Upload to ImageKit directly
  Future<String?> uploadToImageKit(File file) async {
    try {
      debugPrint('Fetching ImageKit auth data...');
      final authData = await getImageKitAuth();
      debugPrint("Auth data received: ${authData.keys.join(', ')}");
      
      final fileName = "product_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      debugPrint('Uploading file: $fileName');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'fileName': fileName,
        'publicKey': authData['publicKey']?.toString(),
        'signature': authData['signature']?.toString(),
        'expire': authData['expire']?.toString(),
        'token': authData['token']?.toString(),
        'useUniqueFileName': 'true',
      });

      debugPrint('FormData created, starting Dio post...');

      // Use a fresh Dio instance for the third-party upload to avoid interference with app interceptors
      final response = await Dio().post(
        'https://upload.imagekit.io/api/v1/files/upload',
        data: formData,
        options: Options(
          validateStatus: (status) => true, // Accept all statuses to read error body
        ),
      );

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.data}');

      if (response.statusCode == 200) {
        String url = response.data['url'];
        // Ensure HEIF/HEIC images are converted to WebP so they render correctly on the web
        final lowerUrl = url.toLowerCase();
        if (lowerUrl.endsWith('.heic') || lowerUrl.endsWith('.heif')) {
          url = url.contains('?') ? '$url&tr=f-webp' : '$url?tr=f-webp';
        }
        return url;
      }
      return null;
    } catch (e) {
      debugPrint('ImageKit upload exception: $e');
      return null;
    }
  }

  // Updated to use client-side ImageKit upload, but fallback to backend for HEIF/HEIC
  Future<bool> createProductNew(Map<String, dynamic> data, List<File> images) async {
    try {
      final formData = FormData.fromMap(data);
      
      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final lowerPath = file.path.toLowerCase();
          
          // ImageKit cannot serve HEIF/HEIC on this tier without returning 400 Bad Request.
          // Send HEIF files directly to our backend so it can convert them to WebP via sharp.
          if (lowerPath.endsWith('.heic') || lowerPath.endsWith('.heif')) {
            formData.files.add(MapEntry(
              'images', 
              await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
            ));
          } else {
            // Upload standard images directly to ImageKit from the mobile app
            final url = await uploadToImageKit(file);
            if (url != null) {
              formData.fields.add(MapEntry('images', url));
            }
          }
        }
      }

      final response = await _apiService.post('/seller/products/create', data: formData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  Future<List<ProductModel>> getMyProducts() async {
    final response = await _apiService.get('/seller/products');
    final List<dynamic> productsJson = response.data['data'] ?? [];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getMyProductById(int id) async {
    final response = await _apiService.get('/seller/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  Future<bool> deleteProduct(int id) async {
    final response = await _apiService.delete('/seller/products/$id');
    return response.data['success'] == true;
  }

  Future<bool> markAsSold(int id) async {
    final response = await _apiService.patch('/seller/products/$id', data: {'status': 'sold'});
    return response.data['success'] == true;
  }

  Future<bool> relistProduct(int id) async {
    final response = await _apiService.patch('/seller/products/$id', data: {'status': 'active'});
    return response.data['success'] == true;
  }

  Future<bool> deactivateProduct(int id) async {
    final response = await _apiService.patch('/seller/products/$id', data: {'status': 'inactive'});
    return response.data['success'] == true;
  }

  Future<ProductModel> updateProduct({
    required int id,
    required String title,
    required String description,
    required double price,
    double? originalPrice,
    required int categoryId,
    required int locationId,
    required String condition,
  }) async {
    final response = await _apiService.patch('/seller/products/$id', data: {
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'category_id': categoryId,
      'location_id': locationId,
      'condition': condition,
    });
    return ProductModel.fromJson(response.data['data']);
  }

  Future<bool> updateProductNew(int id, Map<String, dynamic> data, List<File> newImages) async {
    try {
      final formData = FormData.fromMap(data);
      
      if (newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final file = newImages[i];
          final lowerPath = file.path.toLowerCase();
          
          if (lowerPath.endsWith('.heic') || lowerPath.endsWith('.heif')) {
            formData.files.add(MapEntry(
              'images', 
              await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
            ));
          } else {
            final url = await uploadToImageKit(file);
            if (url != null) {
              formData.fields.add(MapEntry('images', url));
            }
          }
        }
      }

      final response = await _apiService.patch('/seller/products/$id', data: formData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Updated specialized upload to use client-side ImageKit, but fallback to backend for HEIF/HEIC
  Future<bool> uploadProductImages(int productId, List<File> images, {bool isPrimary = false, int displayOrder = 0}) async {
    try {
      final Map<String, dynamic> payload = {
        'product_id': productId.toString(),
        'is_primary': isPrimary.toString(),
        'display_order': displayOrder.toString(),
      };

      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final lowerPath = file.path.toLowerCase();
          
          if (lowerPath.endsWith('.heic') || lowerPath.endsWith('.heif')) {
            payload['image$i'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
          } else {
            final url = await uploadToImageKit(file);
            if (url != null) {
              payload['image$i'] = url;
            }
          }
        }
      }

      final formData = FormData.fromMap(payload);
      final response = await _apiService.post('/upload/product-images', data: formData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error uploading product images: $e');
      return false;
    }
  }

  Future<bool> deleteProductImage(int imageId) async {
    try {
      final response = await _apiService.delete('/upload/product-images', queryParameters: {
        'image_id': imageId.toString(),
      });
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Error deleting product image: $e');
      return false;
    }
  }
}
