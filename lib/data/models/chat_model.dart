class Conversation {
  final int id;
  final int? productId;
  final String? productTitle;
  final double? productPrice;
  final String? productImage;
  final int? senderId;
  final String senderName;
  final String? senderAvatar;
  final int? receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final String? agencyName;
  final String? agencyLogo;
  final bool isAgencyChat;
  final int? agencyIdResolved;
  final int unreadCount;
  final String message;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  Conversation({
    required this.id,
    this.productId,
    this.productTitle,
    this.productPrice,
    this.productImage,
    this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    this.agencyName,
    this.agencyLogo,
    required this.isAgencyChat,
    this.agencyIdResolved,
    this.unreadCount = 0,
    required this.message,
    this.attachmentUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      productId: json['product_id'],
      productTitle: json['product_title'],
      productPrice: json['product_price'] != null ? double.tryParse(json['product_price'].toString()) : null,
      productImage: json['product_image'],
      senderId: json['sender_id'],
      senderName: json['sender_name'] ?? 'Unknown User',
      senderAvatar: json['sender_avatar'],
      receiverId: json['receiver_id'],
      receiverName: json['receiver_name'] ?? 'Unknown User',
      receiverAvatar: json['receiver_avatar'],
      agencyName: json['agency_name'],
      agencyLogo: json['agency_logo'],
      isAgencyChat: json['is_agency_chat'] == 1 || json['is_agency_chat'] == true,
      agencyIdResolved: json['agency_id_resolved'],
      unreadCount: json['unread_count'] ?? 0,
      message: json['message'] ?? '',
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class ChatMessage {
  final int id;
  final int? productId;
  final int? senderId;
  final int? receiverId;
  final int? receiverAgencyId;
  final String message;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;
  final String senderName;
  final String receiverName;
  final String? agencyName;
  final String? agencyLogo;
  final bool isAgencyChat;

  ChatMessage({
    required this.id,
    this.productId,
    this.senderId,
    this.receiverId,
    this.receiverAgencyId,
    required this.message,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
    required this.senderName,
    required this.receiverName,
    this.agencyName,
    this.agencyLogo,
    required this.isAgencyChat,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      productId: json['product_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      receiverAgencyId: json['receiver_agency_id'],
      message: json['message'] ?? '',
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      senderName: json['sender_name'] ?? 'Unknown',
      receiverName: json['receiver_name'] ?? 'Unknown',
      agencyName: json['agency_name'],
      agencyLogo: json['agency_logo'],
      isAgencyChat: json['is_agency_chat'] == 1 || json['is_agency_chat'] == true,
    );
  }
}
