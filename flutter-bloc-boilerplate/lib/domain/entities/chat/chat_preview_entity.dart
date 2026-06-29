import 'package:equatable/equatable.dart';

class ChatPreviewEntity extends Equatable {
  final String bookingId;
  final String chatRoomId;
  final String serviceName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatPreviewEntity({
    required this.bookingId,
    required this.chatRoomId,
    required this.serviceName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  bool get hasUnread => unreadCount > 0;

  factory ChatPreviewEntity.fromJson(Map<String, dynamic> json) =>
      ChatPreviewEntity(
        bookingId: json['booking_id'] as String,
        chatRoomId: json['chat_room_id'] as String,
        serviceName: json['service_name'] as String? ?? '',
        lastMessage: json['last_message'] as String?,
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'] as String)
            : null,
        unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      );

  factory ChatPreviewEntity.fromCacheJson(Map<String, dynamic> json) =>
      ChatPreviewEntity(
        bookingId: json['booking_id'] as String,
        chatRoomId: json['chat_room_id'] as String,
        serviceName: json['service_name'] as String? ?? '',
        lastMessage: json['last_message'] as String?,
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'] as String)
            : null,
        unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toCacheJson() => {
        'booking_id': bookingId,
        'chat_room_id': chatRoomId,
        'service_name': serviceName,
        'last_message': lastMessage,
        if (lastMessageAt != null)
          'last_message_at': lastMessageAt!.toUtc().toIso8601String(),
        'unread_count': unreadCount,
      };

  @override
  List<Object?> get props =>
      [bookingId, chatRoomId, lastMessage, lastMessageAt, unreadCount];
}
