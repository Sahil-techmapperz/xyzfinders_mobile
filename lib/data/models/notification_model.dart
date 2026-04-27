class NotificationModel {
  final int id;
  final int receiverId;
  final int? senderId;
  final String type;
  final String title;
  final String message;
  final String? link;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;

  NotificationModel({
    required this.id,
    required this.receiverId,
    this.senderId,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    required this.isRead,
    required this.createdAt,
    this.senderName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      receiverId: json['receiver_id'],
      senderId: json['sender_id'],
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiver_id': receiverId,
      'sender_id': senderId,
      'type': type,
      'title': title,
      'message': message,
      'link': link,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
    };
  }
}

class NotificationSettingsModel {
  final bool emailMessages;
  final bool emailReviews;
  final bool emailProducts;
  final bool emailPromotions;
  final bool pushMessages;
  final bool pushReviews;

  NotificationSettingsModel({
    this.emailMessages = true,
    this.emailReviews = true,
    this.emailProducts = true,
    this.emailPromotions = false,
    this.pushMessages = true,
    this.pushReviews = true,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      emailMessages: json['email_messages'] == 1 || json['email_messages'] == true,
      emailReviews: json['email_reviews'] == 1 || json['email_reviews'] == true,
      emailProducts: json['email_products'] == 1 || json['email_products'] == true,
      emailPromotions: json['email_promotions'] == 1 || json['email_promotions'] == true,
      pushMessages: json['push_messages'] == 1 || json['push_messages'] == true,
      pushReviews: json['push_reviews'] == 1 || json['push_reviews'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_messages': emailMessages,
      'email_reviews': emailReviews,
      'email_products': emailProducts,
      'email_promotions': emailPromotions,
      'push_messages': pushMessages,
      'push_reviews': pushReviews,
    };
  }

  NotificationSettingsModel copyWith({
    bool? emailMessages,
    bool? emailReviews,
    bool? emailProducts,
    bool? emailPromotions,
    bool? pushMessages,
    bool? pushReviews,
  }) {
    return NotificationSettingsModel(
      emailMessages: emailMessages ?? this.emailMessages,
      emailReviews: emailReviews ?? this.emailReviews,
      emailProducts: emailProducts ?? this.emailProducts,
      emailPromotions: emailPromotions ?? this.emailPromotions,
      pushMessages: pushMessages ?? this.pushMessages,
      pushReviews: pushReviews ?? this.pushReviews,
    );
  }
}
