import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';
import '../../core/errors/api_exception.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load demo products for testing
  void loadDemoProducts() {
    _products = _getDemoProducts();
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  List<ProductModel> _getDemoProducts() {
    return [
      ProductModel(
        id: 1,
        userId: 1,
        categoryId: 1,
        locationId: 1,
        title: 'iPhone 13 Pro Max',
        description: 'Brand new iPhone 13 Pro Max 256GB in Sierra Blue. Never used, still in original packaging.',
        price: 999.99,
        originalPrice: 1199.99,
        condition: 'new',
        status: 'active',
        isFeatured: true,
        viewsCount: 245,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        category: {'id': 1, 'name': 'Electronics'},
        location: {'id': 1, 'name': 'New York'},
      ),
      ProductModel(
        id: 2,
        userId: 1,
        categoryId: 2,
        locationId: 1,
        title: 'Gaming Laptop - RTX 3080',
        description: 'High-performance gaming laptop with RTX 3080, 32GB RAM, 1TB SSD. Perfect for gaming and video editing.',
        price: 1499.00,
        condition: 'like_new',
        status: 'active',
        isFeatured: false,
        viewsCount: 189,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        category: {'id': 2, 'name': 'Computers'},
        location: {'id': 1, 'name': 'New York'},
      ),
      ProductModel(
        id: 3,
        userId: 2,
        categoryId: 3,
        locationId: 2,
        title: 'Modern Sofa Set',
        description: 'Beautiful 3-seater sofa in excellent condition. Comfortable and stylish for any living room.',
        price: 450.00,
        condition: 'good',
        status: 'active',
        isFeatured: false,
        viewsCount: 67,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        category: {'id': 3, 'name': 'Furniture'},
        location: {'id': 2, 'name': 'Los Angeles'},
      ),
    ];
  }

  // Fetch products (first page or refresh)
  Future<void> fetchProducts({
    int? categoryId,
    int? locationId,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _productService.getProducts(
        page: _currentPage,
        categoryId: categoryId,
        locationId: locationId,
        condition: condition,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
      );

      _products = result['products'] as List<ProductModel>;
      final pagination = result['pagination'];
      _currentPage = pagination['current_page'];
      _totalPages = pagination['total_pages'];
      _hasMore = _currentPage < _totalPages;

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more products (pagination)
  Future<void> loadMore({
    int? categoryId,
    int? locationId,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _productService.getProducts(
        page: _currentPage + 1,
        categoryId: categoryId,
        locationId: locationId,
        condition: condition,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
      );

      final newProducts = result['products'] as List<ProductModel>;
      _products.addAll(newProducts);

      final pagination = result['pagination'];
      _currentPage = pagination['current_page'];
      _totalPages = pagination['total_pages'];
      _hasMore = _currentPage < _totalPages;

      _isLoadingMore = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch single product detail
  Future<void> fetchProductDetail(int id) async {
    _isLoading = true;
    _error = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      final product = await _productService.getProductById(id);
      _selectedProduct = product;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Ad
  Future<bool> createAd(Map<String, dynamic> data, List<File> images) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _productService.createProductNew(data, images);
      _isLoading = false;
      if (!success) {
        _error = 'Failed to create ad. Please try again.';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear products
  void clear() {
    _products = [];
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
