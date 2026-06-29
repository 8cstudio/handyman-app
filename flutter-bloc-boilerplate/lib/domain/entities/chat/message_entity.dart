import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String senderName;
  final String senderId;
  final String messageType;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.senderName,
    required this.senderId,
    required this.messageType,
    required this.createdAt,
    this.readAt,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) => MessageEntity(
        id: json['id'] as String,
        content: json['content'] as String,
        senderId: json['sender_id'] as String,
        senderName: (json['profiles'] as Map?)?['full_name'] as String? ??
            json['sender_name'] as String? ??
            '',
        messageType: json['message_type'] as String? ?? 'text',
        createdAt: DateTime.parse(json['created_at'] as String),
        readAt: json['read_at'] != null
            ? DateTime.parse(json['read_at'] as String)
            : null,
      );

  factory MessageEntity.fromCacheJson(Map<String, dynamic> json) =>
      MessageEntity(
        id: json['id'] as String,
        content: json['content'] as String,
        senderId: json['sender_id'] as String,
        senderName: json['sender_name'] as String? ?? '',
        messageType: json['message_type'] as String? ?? 'text',
        createdAt: DateTime.parse(json['created_at'] as String),
        readAt: json['read_at'] != null
            ? DateTime.parse(json['read_at'] as String)
            : null,
      );

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'content': content,
        'sender_id': senderId,
        'sender_name': senderName,
        'message_type': messageType,
        'created_at': createdAt.toUtc().toIso8601String(),
        if (readAt != null) 'read_at': readAt!.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [id, content, createdAt, readAt];
}
