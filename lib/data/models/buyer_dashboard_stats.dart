import '../models/product_model.dart';

class BuyerActivity {
  final String type; // application, wishlist
  final String createdAt;
  final String itemTitle;
  final String detail;

  BuyerActivity({
    required this.type,
    required this.createdAt,
    required this.itemTitle,
    required this.detail,
  });

  factory BuyerActivity.fromJson(Map<String, dynamic> json) {
    return BuyerActivity(
      type: json['type'] ?? '',
      createdAt: json['created_at'] ?? '',
      itemTitle: json['item_title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

class BuyerDashboardStats {
  final int wishlistCount;
  final double wishlistValue;
  final int applicationsCount;
  final int unreadMessages;
  final int priceDrops;
  final List<ProductModel> recommendedProducts;
  final List<BuyerActivity> recentActivity;

  BuyerDashboardStats({
    required this.wishlistCount,
    required this.wishlistValue,
    required this.applicationsCount,
    required this.unreadMessages,
    required this.priceDrops,
    required this.recommendedProducts,
    required this.recentActivity,
  });

  factory BuyerDashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    
    final recommended = (json['recommendedProducts'] as List? ?? [])
        .map((e) => ProductModel.fromJson(e))
        .toList();

    final activities = (json['recentActivity'] as List? ?? [])
        .map((e) => BuyerActivity.fromJson(e))
        .toList();

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

    return BuyerDashboardStats(
      wishlistCount: (stats['wishlistCount'] ?? 0) as int,
      wishlistValue: safeParseDouble(stats['wishlistValue'] ?? stats['total_value']),
      applicationsCount: (stats['applicationsCount'] ?? 0) as int,
      unreadMessages: (stats['unreadMessages'] ?? 0) as int,
      priceDrops: (stats['priceDrops'] ?? 0) as int,
      recommendedProducts: recommended,
      recentActivity: activities,
    );
  }
}
