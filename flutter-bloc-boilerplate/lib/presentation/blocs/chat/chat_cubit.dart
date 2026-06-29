import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  static const _messagePageSize = 30;

  final HandymanRepository _repository;
  String? _chatRoomId;

  ChatCubit({required HandymanRepository repository})
      : _repository = repository,
        super(const ChatInitial());

  Future<void> openChat(String bookingId) async {
    try {
      _chatRoomId = await _repository.getChatRoomId(bookingId);
      if (_chatRoomId == null) {
        emit(const ChatError('Chat not available yet'));
        return;
      }

      final cached = await _repository.getCachedMessages(_chatRoomId!);
      if (cached != null && cached.messages.isNotEmpty) {
        emit(MessagesLoaded(
          cached.messages,
          hasMoreOlder: cached.hasMoreOlder,
        ));
      } else {
        emit(const ChatLoading());
      }

      _repository.subscribeToMessages(_chatRoomId!, _onMessagesChanged);
      unawaited(_syncLatestMessages());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _syncLatestMessages() async {
    if (_chatRoomId == null) return;
    final result = await _repository.getMessages(
      _chatRoomId!,
      limit: _messagePageSize,
    );
    if (isClosed) return;
    emit(MessagesLoaded(
      result.messages,
      hasMoreOlder: result.hasMore,
    ));
    await _repository.markMessagesRead(_chatRoomId!);
  }

  Future<void> loadOlderMessages() async {
    if (_chatRoomId == null || state is! MessagesLoaded) return;
    final current = state as MessagesLoaded;
    if (current.isLoadingOlder || !current.hasMoreOlder || current.messages.isEmpty) {
      return;
    }

    emit(MessagesLoaded(
      current.messages,
      hasMoreOlder: current.hasMoreOlder,
      isLoadingOlder: true,
    ));

    try {
      final oldest = current.messages.first;
      final result = await _repository.getMessages(
        _chatRoomId!,
        limit: _messagePageSize,
        before: oldest.createdAt,
      );
      if (isClosed) return;
      emit(MessagesLoaded(
        [...result.messages, ...current.messages],
        hasMoreOlder: result.hasMore,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(MessagesLoaded(
        current.messages,
        hasMoreOlder: current.hasMoreOlder,
      ));
    }
  }

  Future<void> _onMessagesChanged() async {
    if (_chatRoomId == null || state is! MessagesLoaded) return;
    final current = state as MessagesLoaded;
    await _refreshTail();
    if (state is MessagesLoaded) {
      final updated = state as MessagesLoaded;
      if (updated.messages.length == current.messages.length) {
        await _syncReadStatuses(current);
      }
    }
  }

  Future<void> _syncReadStatuses(MessagesLoaded current) async {
    if (_chatRoomId == null) return;
    try {
      final limit = current.messages.length.clamp(_messagePageSize, 100);
      final result = await _repository.getMessages(
        _chatRoomId!,
        limit: limit,
      );
      if (isClosed || state is! MessagesLoaded || result.messages.isEmpty) return;
      final merged = _mergeMessagesById(current.messages, result.messages);
      emit(MessagesLoaded(
        merged,
        hasMoreOlder: current.hasMoreOlder,
      ));
    } catch (_) {}
  }

  List<MessageEntity> _mergeMessagesById(
    List<MessageEntity> existing,
    List<MessageEntity> latest,
  ) {
    final latestById = {for (final msg in latest) msg.id: msg};
    return existing
        .map((msg) => latestById[msg.id] ?? msg)
        .toList(growable: false);
  }

  Future<void> _refreshTail() async {
    if (_chatRoomId == null || state is! MessagesLoaded) return;
    final current = state as MessagesLoaded;
    if (current.messages.isEmpty) {
      await _syncLatestMessages();
      return;
    }

    try {
      final last = current.messages.last;
      final result = await _repository.getMessages(
        _chatRoomId!,
        limit: _messagePageSize,
        after: last.createdAt,
      );
      if (result.messages.isEmpty) return;
      if (isClosed) return;
      emit(MessagesLoaded(
        [...current.messages, ...result.messages],
        hasMoreOlder: current.hasMoreOlder,
      ));
      await _repository.markMessagesRead(_chatRoomId!);
    } catch (_) {}
  }

  Future<void> sendMessage(String content) async {
    if (_chatRoomId == null || content.trim().isEmpty) return;
    try {
      final message = await _repository.sendMessage(
        chatRoomId: _chatRoomId!,
        content: content.trim(),
      );
      if (isClosed) return;
      if (state is MessagesLoaded) {
        final current = state as MessagesLoaded;
        final alreadyShown = current.messages.any((m) => m.id == message.id);
        emit(MessagesLoaded(
          alreadyShown ? current.messages : [...current.messages, message],
          hasMoreOlder: current.hasMoreOlder,
        ));
      } else {
        emit(MessagesLoaded([message], hasMoreOlder: false));
      }
      await _repository.markMessagesRead(_chatRoomId!);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _repository.unsubscribeFromMessages();
    return super.close();
  }
}
