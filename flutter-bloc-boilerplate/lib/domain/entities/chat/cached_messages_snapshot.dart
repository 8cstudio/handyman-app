import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';

class CachedMessagesSnapshot {
  final List<MessageEntity> messages;
  final bool hasMoreOlder;

  const CachedMessagesSnapshot({
    required this.messages,
    this.hasMoreOlder = false,
  });
}
