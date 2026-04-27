import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/category_model.dart';
import 'package:flutter/foundation.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories({bool featuredOnly = false}) async {
    try {
      final endpoint = featuredOnly 
          ? '${ApiConstants.categories}?featured=true' 
          : ApiConstants.categories;
          
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null && response.data is Map) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> list = responseData['data'];
          return list.map((json) => CategoryModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      final response = await _apiService.get(ApiConstants.categoryById(id));

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          return CategoryModel.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching category by ID ($id): $e');
      throw Exception('Failed to fetch category detail');
    }
  }
}
