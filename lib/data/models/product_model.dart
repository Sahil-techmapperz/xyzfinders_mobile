class ProductModel {
  final int id;
  final int userId;
  final int? categoryId;
  final int? locationId;
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
  
  // Dynamic Attributes
  final Map<String, dynamic>? productAttributes;
  
  // Flat fields from API response for easier access
  final String? sellerName;
  final String? sellerAvatar;
  final String? sellerPhone;
  final String? sellerCreatedAt;
  final bool sellerIsVerified;
  final String? categoryName;
  final String? cityName;
  final String? stateName;
  final String? locationName;
  final String? postalCode;

  // Relationships (can be null if not included)
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? location;
  final List<Map<String, dynamic>>? images;
  final String? thumbnail;

  ProductModel({
    required this.id,
    required this.userId,
    this.categoryId,
    this.locationId,
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
    this.productAttributes,
    this.sellerName,
    this.sellerAvatar,
    this.sellerPhone,
    this.sellerCreatedAt,
    this.sellerIsVerified = false,
    this.categoryName,
    this.cityName,
    this.stateName,
    this.locationName,
    this.postalCode,
    this.user,
    this.category,
    this.location,
    this.images,
    this.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      final parsed = int.tryParse(value.toString());
      if (parsed == 0) return null; // Treat 0 as null for dropdown safety
      return parsed;
    }

    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      try {
        return double.parse(value.toString());
      } catch (_) {
        return 0.0;
      }
    }

    // Handle product_attributes which might be a JSON string or an object
    Map<String, dynamic>? attributes;
    if (json['product_attributes'] != null) {
      if (json['product_attributes'] is Map) {
        attributes = Map<String, dynamic>.from(json['product_attributes']);
      }
    }

    return ProductModel(
      id: parseInt(json['id']) ?? 0,
      userId: parseInt(json['user_id']) ?? 0,
      categoryId: parseInt(json['category_id']),
      locationId: parseInt(json['location_id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: safeParseDouble(json['price']),
      originalPrice: json['original_price'] != null 
          ? safeParseDouble(json['original_price']) 
          : null,
      condition: (json['condition'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      viewsCount: parseInt(json['views']) ?? 0,
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      productAttributes: attributes,
      sellerName: json['seller_name'],
      sellerAvatar: json['seller_avatar'],
      sellerPhone: json['seller_phone'],
      sellerCreatedAt: json['seller_created_at'],
      sellerIsVerified: json['seller_is_verified'] == 1 || json['seller_is_verified'] == true,
      categoryName: json['category_name'],
      cityName: json['city_name'],
      stateName: json['state_name'],
      locationName: json['location_name'],
      postalCode: json['postal_code'],
      user: json['user'],
      category: json['category'],
      location: json['location'],
      images: json['images'] != null 
          ? List<Map<String, dynamic>>.from(json['images'] as List) 
          : null,
      thumbnail: json['thumbnail'] as String?,
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
      'product_attributes': productAttributes,
      'seller_name': sellerName,
      'seller_avatar': sellerAvatar,
      'seller_phone': sellerPhone,
      'seller_created_at': sellerCreatedAt,
      'seller_is_verified': sellerIsVerified,
      'category_name': categoryName,
      'city_name': cityName,
      'state_name': stateName,
      'location_name': locationName,
      'postal_code': postalCode,
      'user': user,
      'category': category,
      'location': location,
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  String? get firstImageUrl {
    if (images != null && images!.isNotEmpty) {
      final imgData = images!.first;
      final imageVal = imgData['image']?.toString() ?? imgData['id']?.toString();
      
      if (imageVal == null) return thumbnail;
      if (imageVal.startsWith('http')) return imageVal;
      return imageVal;
    }
    return thumbnail;
  }

  List<String> get allImageUrls {
    if (images == null || images!.isEmpty) return [];
    return images!.map((img) {
      final val = img['image']?.toString() ?? img['id']?.toString() ?? '';
      return val;
    }).where((s) => s.isNotEmpty).toList();
  }

  String? resolveImageUrl(String baseUrl) {
    String? imageVal;
    if (images != null && images!.isNotEmpty) {
      final imgData = images!.first;
      imageVal = imgData['image']?.toString() ?? imgData['id']?.toString();
    }
    
    imageVal ??= thumbnail;
    
    if (imageVal == null) return null;
    if (imageVal.startsWith('http')) return imageVal;
    if (imageVal.startsWith('data:image')) return imageVal;
    
    // Heuristic for base64
    if (imageVal.length > 500) return imageVal;
    
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    return "$cleanBaseUrl/images/product/$imageVal";
  }
}
