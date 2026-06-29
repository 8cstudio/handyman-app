import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/presentation/blocs/chat/chat_cubit.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/widgets/chat_message_bubble.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_app_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class ChatScreen extends StatelessWidget {
  final String bookingId;
  const ChatScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatCubit>()..openChat(bookingId),
      child: const _ChatScreenBody(),
    );
  }
}

class _ChatScreenBody extends StatefulWidget {
  const _ChatScreenBody();

  @override
  State<_ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<_ChatScreenBody> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? get _currentUserId => SupabaseService.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      context.read<ChatCubit>().loadOlderMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassShell(
      appBar: GlassAppBar(title: const Text(AppText.chat)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hello!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }

                  final itemCount =
                      state.messages.length + (state.isLoadingOlder ? 1 : 0);

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (state.isLoadingOlder &&
                          index == state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final msg =
                          state.messages[state.messages.length - 1 - index];
                      final isMine = msg.senderId == _currentUserId;
                      return ChatMessageBubble(message: msg, isMine: isMine);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: GlassContainer(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                borderRadius: GlassStyle.radiusXl,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: GlassStyle.inputDecoration(
                          context,
                          hintText: 'Type a message...',
                        ).copyWith(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onSubmitted: (text) => _sendMessage(context, text),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _sendMessage(context, _controller.text),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _controller.clear();
  }
}

class ReviewScreen extends StatefulWidget {
  final String bookingId;
  const ReviewScreen({super.key, required this.bookingId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>(),
      child: BlocListener<HandymanCubit, HandymanState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<HandymanCubit>().clearSuccessMessage();
            context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text(AppText.writeReview)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(i < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      onPressed: () => setState(() => _rating = i + 1),
                    );
                  }),
                ),
                TextField(
                  controller: _comment,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText: 'Write your review (optional)'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.read<HandymanCubit>().submitReview(
                        bookingId: widget.bookingId,
                        rating: _rating,
                        comment: _comment.text.trim(),
                      ),
                  child: const Text(AppText.submitReview),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
