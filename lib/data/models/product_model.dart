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
    return ProductModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      locationId: json['location_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: double.parse(json['price'].toString()),
      originalPrice: json['original_price'] != null 
          ? double.parse(json['original_price'].toString()) 
          : null,
      condition: json['condition'] as String,
      status: json['status'] as String,
      // Handle both int (0/1) and bool
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      viewsCount: (json['views'] ?? 0) as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
          : null,
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
      final imageId = images!.first['id'];
      return '/api/images/product/$imageId';
    }
    return null;
  }
}
