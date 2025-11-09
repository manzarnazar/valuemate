class SupportChatRoom {
  final int id;
  final int userId;
  final DateTime? createdAt;

  SupportChatRoom({
    required this.id,
    required this.userId,
    this.createdAt,
  });

  factory SupportChatRoom.fromJson(Map<String, dynamic> json) {
    return SupportChatRoom(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }
}

class SupportChatMessage {
  final int id;
  final String message;
  final int senderId;
  final String senderName;
  final bool isAdmin;
  final bool isRead;
  final String? createdAt;
  final String? createdAtHuman;

  SupportChatMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.isRead,
    this.createdAt,
    this.createdAtHuman,
  });

  factory SupportChatMessage.fromJson(Map<String, dynamic> json) {
    return SupportChatMessage(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      message: json['message']?.toString() ?? '',
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.tryParse('${json['sender_id']}') ?? 0,
      senderName: json['sender_name']?.toString() ?? '',
      isAdmin: _parseBool(json['is_admin']),
      isRead: _parseBool(json['is_read']),
      createdAt: json['created_at']?.toString(),
      createdAtHuman: json['created_at_human']?.toString(),
    );
  }
}

class SupportChatRoomResponse {
  final bool status;
  final SupportChatRoom? room;
  final String? message;

  SupportChatRoomResponse({
    required this.status,
    this.room,
    this.message,
  });

  factory SupportChatRoomResponse.fromJson(Map<String, dynamic> json) {
    return SupportChatRoomResponse(
      status: _parseBool(json['status']),
      room: json['data'] is Map<String, dynamic>
          ? SupportChatRoom.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class SupportChatMessagesResponse {
  final bool status;
  final List<SupportChatMessage> messages;
  final String? message;

  SupportChatMessagesResponse({
    required this.status,
    required this.messages,
    this.message,
  });

  factory SupportChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SupportChatMessagesResponse(
      status: _parseBool(json['status']),
      messages: data is List
          ? data
              .whereType<Map<String, dynamic>>()
              .map(SupportChatMessage.fromJson)
              .toList()
          : [],
      message: json['message']?.toString(),
    );
  }
}

class SupportChatSendResponse {
  final bool status;
  final String? message;
  final SupportChatMessage? sentMessage;

  SupportChatSendResponse({
    required this.status,
    this.message,
    this.sentMessage,
  });

  factory SupportChatSendResponse.fromJson(Map<String, dynamic> json) {
    return SupportChatSendResponse(
      status: _parseBool(json['status']),
      message: json['message']?.toString(),
      sentMessage: json['data'] is Map<String, dynamic>
          ? SupportChatMessage.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' ||
        lower == '1' ||
        lower == 'yes' ||
        lower == 'on';
  }
  return false;
}

