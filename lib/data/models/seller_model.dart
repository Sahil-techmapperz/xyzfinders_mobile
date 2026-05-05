class SellerModel {
  final int id;
  final String companyName;
  final String? sellerType;
  final String? avatar;
  final String? address;
  final bool isVerified;
  final String? userName;
  final int adCount;
  final int? joinedYear;
  final String? storeBanner;
  final Map<String, dynamic>? socialLinks;

  SellerModel({
    required this.id,
    required this.companyName,
    this.sellerType,
    this.avatar,
    this.address,
    required this.isVerified,
    this.userName,
    required this.adCount,
    this.joinedYear,
    this.storeBanner,
    this.socialLinks,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as int? ?? 0,
      companyName: json['company_name'] as String? ?? '',
      sellerType: json['seller_type'] as String?,
      avatar: json['avatar'] as String?,
      address: json['address'] as String?,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      userName: json['user_name'] as String?,
      adCount: json['ad_count'] as int? ?? 0,
      joinedYear: json['joined_year'] as int?,
      storeBanner: json['store_banner'] as String?,
      socialLinks: json['social_links'] is Map ? Map<String, dynamic>.from(json['social_links'] as Map) : null,
    );
  }
}
