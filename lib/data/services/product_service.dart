import '../models/product_model.dart';
import '../../core/config/api_service.dart';
import '../../core/constants/api_constants.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Get all products with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    int? locationId,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort': 'created_at',  // Sort by creation date
      'order': 'desc',        // Newest first
    };

    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (locationId != null) queryParams['location_id'] = locationId;
    if (condition != null) queryParams['condition'] = condition;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiService.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List;
    final products = data.map((json) => ProductModel.fromJson(json)).toList();

    final pagination = response.data['pagination'];

    return {
      'products': products,
      'pagination': pagination,
    };
  }

  // Get single product by ID
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiService.get(
      ApiConstants.productById(id),
    );

    return ProductModel.fromJson(response.data['data']);
  }

  // Get user's products
  Future<List<ProductModel>> getMyProducts() async {
    final response = await _apiService.get(ApiConstants.myProducts);
    final data = response.data['data'] as List;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  // Create new product
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required int locationId,
    required String condition,
    double? originalPrice,
  }) async {
    final response = await _apiService.post(
      ApiConstants.products,
      data: {
        'title': title,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'location_id': locationId,
        'condition': condition,
        if (originalPrice != null) 'original_price': originalPrice,
      },
    );

    return ProductModel.fromJson(response.data['data']);
  }

  // Update product
  Future<ProductModel> updateProduct({
    required int id,
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required int locationId,
    required String condition,
    double? originalPrice,
  }) async {
    final response = await _apiService.put(
      ApiConstants.productById(id),
      data: {
        'title': title,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'location_id': locationId,
        'condition': condition,
        if (originalPrice != null) 'original_price': originalPrice,
      },
    );

    return ProductModel.fromJson(response.data['data']);
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    await _apiService.delete(ApiConstants.productById(id));
  }

  // Mark product as sold
  Future<ProductModel> markAsSold(int id) async {
    final response = await _apiService.post(
      ApiConstants.markProductSold(id),
    );

    return ProductModel.fromJson(response.data['data']);
  }
}
