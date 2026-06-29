part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class MessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool hasMoreOlder;
  final bool isLoadingOlder;

  const MessagesLoaded(
    this.messages, {
    this.hasMoreOlder = false,
    this.isLoadingOlder = false,
  });

  @override
  List<Object?> get props => [messages, hasMoreOlder, isLoadingOlder];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
