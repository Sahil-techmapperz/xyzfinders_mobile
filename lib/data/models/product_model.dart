import 'dart:convert';

class ProductModel {
  final int id;
  final int userId;
  final int? agencyId;
  final int? agentId;
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
  final int applicantsCount;
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
  final String? companyLogo;

  // Relationships (can be null if not included)
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? location;
  final List<Map<String, dynamic>>? images;
  final String? thumbnail;

  ProductModel({
    required this.id,
    required this.userId,
    this.agencyId,
    this.agentId,
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
    this.applicantsCount = 0,
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
    this.companyLogo,
    this.user,
    this.category,
    this.location,
    this.images,
    this.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? attributes;
    if (json['product_attributes'] != null) {
      if (json['product_attributes'] is Map) {
        attributes = Map<String, dynamic>.from(json['product_attributes']);
      } else if (json['product_attributes'] is String && json['product_attributes'].toString().isNotEmpty) {
        try {
          attributes = jsonDecode(json['product_attributes'].toString()) as Map<String, dynamic>;
        } catch (_) {}
      }
    }

    // Deep parsing for legacy or complex structures where attributes are nested
    if (attributes != null && attributes.containsKey('product_attributes')) {
      final nested = attributes['product_attributes'];
      if (nested is String && nested.isNotEmpty) {
        try {
          final decodedNested = jsonDecode(nested);
          if (decodedNested is Map) {
            // Flatten 'specs' and 'details' if they exist in the nested JSON
            if (decodedNested.containsKey('specs') && decodedNested['specs'] is Map) {
              attributes.addAll(Map<String, dynamic>.from(decodedNested['specs']));
            }
            if (decodedNested.containsKey('details') && decodedNested['details'] is Map) {
              attributes.addAll(Map<String, dynamic>.from(decodedNested['details']));
            }
            // Also merge the whole thing just in case
            attributes.addAll(Map<String, dynamic>.from(decodedNested));
          }
        } catch (_) {}
      }
    }

    return ProductModel(
      id: parseInt(json['id']) ?? 0,
      userId: parseInt(json['user_id']) ?? 0,
      agencyId: parseInt(json['agency_id']),
      agentId: parseInt(json['agent_id']),
      categoryId: parseInt(json['category_id']),
      locationId: parseInt(json['location_id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? json['content'] ?? json['body'] ?? '').toString(),
      price: safeParseDouble(json['price']),
      originalPrice: json['original_price'] != null 
          ? safeParseDouble(json['original_price']) 
          : null,
      condition: (json['condition'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      viewsCount: parseInt(json['views']) ?? 0,
      applicantsCount: parseInt(json['applicants_count']) ?? parseInt(json['applications_count']) ?? 0,
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      productAttributes: attributes,
      sellerName: json['seller_name'] ?? json['name'],
      sellerAvatar: json['seller_avatar'] ?? json['avatar'],
      sellerPhone: json['seller_phone'] ?? json['phone'] ?? json['mobile'],
      sellerCreatedAt: json['seller_created_at'],
      sellerIsVerified: json['seller_is_verified'] == 1 || json['seller_is_verified'] == true,
      categoryName: json['category_name'] ?? (json['category'] is Map ? json['category']['name'] : null),
      cityName: json['city'] ?? json['city_name'] ?? (json['location'] is Map ? json['location']['city'] : null),
      stateName: json['state_name'] ?? json['state'] ?? (json['location'] is Map ? json['location']['state'] : null),
      locationName: json['location_name'] ?? json['locationArea'] ?? (json['location'] is Map ? json['location']['name'] : null),
      postalCode: json['postal_code'] ?? json['pincode'],
      companyLogo: json['company_logo'],
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      category: json['category'] is Map ? Map<String, dynamic>.from(json['category']) : null,
      location: json['location'] is Map ? Map<String, dynamic>.from(json['location']) : null,
      images: json['images'] != null 
          ? (json['images'] as List).map((img) {
              if (img is Map) return Map<String, dynamic>.from(img);
              return {'image': img.toString(), 'id': img.toString()};
            }).toList()
          : null,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agency_id': agencyId,
      'agent_id': agentId,
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
      'applicants_count': applicantsCount,
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
      'company_logo': companyLogo,
      'user': user,
      'category': category,
      'location': location,
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final parsed = int.tryParse(value.toString());
    if (parsed == 0) return null;
    return parsed;
  }

  static double safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    try {
      return double.parse(value.toString());
    } catch (_) {
      return 0.0;
    }
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
    
    imageVal = (imageVal ?? thumbnail ?? '').trim();
    
    if (imageVal.isEmpty) return null;
    if (imageVal.toLowerCase().startsWith('http')) return imageVal;
    if (imageVal.toLowerCase().startsWith('data:image')) return imageVal;
    
    // Heuristic for base64
    if (imageVal.length > 500) return imageVal;
    
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    final cleanVal = imageVal.startsWith('/') ? imageVal.substring(1) : imageVal;
    return "$cleanBaseUrl/images/product/$cleanVal";
  }
}
