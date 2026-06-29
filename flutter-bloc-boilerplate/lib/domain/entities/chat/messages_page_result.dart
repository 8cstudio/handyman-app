import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';

class MessagesPageResult {
  final List<MessageEntity> messages;
  final bool hasMore;

  const MessagesPageResult({
    required this.messages,
    required this.hasMore,
  });
}
