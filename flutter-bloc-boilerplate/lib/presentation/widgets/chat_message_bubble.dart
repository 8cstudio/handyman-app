import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 56 : 8,
        right: isMine ? 8 : 56,
        bottom: 8,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isMine ? 22 : 6),
                bottomRight: Radius.circular(isMine ? 6 : 22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isMine
                    ? [
                        primary.withValues(alpha: 0.92),
                        primary.withValues(alpha: 0.72),
                      ]
                    : [
                        GlassStyle.glassFill(context),
                        GlassStyle.glassFill(context)
                            .withValues(alpha: GlassStyle.glassFill(context).a * 0.7),
                      ],
              ),
              border: Border.all(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.28)
                    : GlassStyle.glassBorder(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isMine ? primary : Colors.black)
                      .withValues(alpha: context.isDarkMode ? 0.18 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMine && message.senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primary.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: isMine
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isMine
                              ? Colors.white.withValues(alpha: 0.78)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.isRead
                              ? Colors.lightBlueAccent.withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.78),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
