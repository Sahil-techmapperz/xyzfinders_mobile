class ProductModel {
  final int id;
  final int userId;
  final int categoryId;
  final int locationId;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String condition;
  final String status;
  final bool isFeatured;
  final int viewsCount;
  final String createdAt;
  final String updatedAt;
  
  // Relationships (can be null if not included)
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? location;
  final List<Map<String, dynamic>>? images;

  ProductModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.locationId,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.condition,
    required this.status,
    required this.isFeatured,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.category,
    this.location,
    this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ProductModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      categoryId: parseInt(json['category_id']),
      locationId: parseInt(json['location_id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: parseDouble(json['price']),
      originalPrice: json['original_price'] != null 
          ? parseDouble(json['original_price']) 
          : null,
      condition: (json['condition'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      // Handle both int (0/1) and bool
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      viewsCount: parseInt(json['views']),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      // Build user object from flat fields if available
      user: json['seller_name'] != null ? {
        'name': json['seller_name'],
        'phone': json['seller_phone'],
      } : null,
      // Build category object from flat fields if available
      category: json['category_name'] != null ? {
        'id': json['category_id'],
        'name': json['category_name'],
      } : null,
      // Build location object from flat fields if available
      location: json['city'] != null ? {
        'id': json['location_id'],
        'name': json['city'],
        'city_name': json['city_name'],
        'state': json['state'],
      } : null,
      images: json['images'] != null 
          ? List<Map<String, dynamic>>.from(json['images'] as List) 
          : (json['primary_image_id'] != null 
              ? [{'id': json['primary_image_id']}] 
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'location_id': locationId,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'condition': condition,
      'status': status,
      'is_featured': isFeatured,
      'views': viewsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user,
      'category': category,
      'location': location,
      'images': images,
    };
  }

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  String? get firstImageUrl {
    if (images != null && images!.isNotEmpty) {
      final imageId = images!.first['id'].toString();
      if (imageId.startsWith('http')) {
        return imageId;
      }
      return '/api/images/product/$imageId?t=${DateTime.now().millisecondsSinceEpoch}';
    }
    return null;
  }

  String? resolveImageUrl(String baseUrl) {
    final url = firstImageUrl;
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    return '$baseUrl$url';
  }
}
