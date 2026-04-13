import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/chat_detail_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showProfileImageAndNickname;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showProfileImageAndNickname,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = Text(
      _formatMessageTime(message.createdAt),
      style: const TextStyle(fontSize: 14, color: AppColors.black),
    );

    final bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.brandMint : AppColors.gray100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.content,
          style: const TextStyle(fontSize: 18, color: AppColors.black),
        ),
      ),
    );

    final profile = showProfileImageAndNickname
        ? CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gray200,
            backgroundImage: message.senderProfileImageUrl == null
                ? null
                : NetworkImage(message.senderProfileImageUrl!),
            child: message.senderProfileImageUrl == null
                ? const Icon(Icons.person, size: 20, color: AppColors.gray600)
                : null,
          )
        : const SizedBox(width: 36);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: isMine
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [timeText, const SizedBox(width: 8), bubble],
              )
            : showProfileImageAndNickname
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 4),
                    child: Text(
                      message.senderNickname ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      profile,
                      const SizedBox(width: 8),
                      bubble,
                      const SizedBox(width: 8),
                      timeText,
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 36),
                  const SizedBox(width: 8),
                  bubble,
                  const SizedBox(width: 8),
                  timeText,
                ],
              ),
      ),
    );
  }

  static String _formatMessageTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
