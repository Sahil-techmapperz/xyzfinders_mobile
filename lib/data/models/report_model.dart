class ReportModel {
  final int id;
  final String reason;
  final String? description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int productId;
  final String productTitle;
  final double productPrice;

  ReportModel({
    required this.id,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      reason: json['reason'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      productId: json['product_id'] is String ? int.parse(json['product_id']) : json['product_id'],
      productTitle: json['product_title'],
      productPrice: double.parse(json['product_price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product_id': productId,
      'product_title': productTitle,
      'product_price': productPrice,
    };
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isResolved => status == 'resolved';
  bool get isDismissed => status == 'dismissed';
}
