import 'product_model.dart';

class SellerDashboardStats {
  final int activeAds;
  final int totalViews;
  final int unreadMessages;
  final int pendingReports;
  final int totalApplicants;
  final List<ProductModel> recentProducts;

  SellerDashboardStats({
    required this.activeAds,
    required this.totalViews,
    required this.unreadMessages,
    required this.pendingReports,
    required this.totalApplicants,
    required this.recentProducts,
  });

  factory SellerDashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    final recent = (json['recentProducts'] as List? ?? [])
        .map((e) => ProductModel.fromJson(e))
        .toList();

    return SellerDashboardStats(
      activeAds: stats['activeAds'] ?? 0,
      totalViews: stats['totalViews'] != null ? int.tryParse(stats['totalViews'].toString()) ?? 0 : 0,
      unreadMessages: stats['unreadMessages'] ?? 0,
      pendingReports: stats['pendingReports'] ?? 0,
      totalApplicants: stats['totalApplicants'] ?? 0,
      recentProducts: recent,
    );
  }
}
