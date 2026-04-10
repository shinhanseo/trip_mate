import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class ChatRoomCard extends StatelessWidget {
  const ChatRoomCard({
    super.key,
    required this.title,
    required this.placeText,
    required this.scheduledAt,
    required this.lastMessageContent,
    required this.lastMessageCreatedAt,
    required this.onTap,
  });

  final String title;
  final String placeText;
  final DateTime scheduledAt;
  final String? lastMessageContent;
  final DateTime? lastMessageCreatedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLastMessage =
        lastMessageContent != null && lastMessageContent!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gray200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        placeText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 22,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatMeetingDateTime(scheduledAt),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLastMessage ? lastMessageContent! : '아직 메시지가 없습니다.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: hasLastMessage
                            ? AppColors.gray500
                            : AppColors.gray400,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (hasLastMessage && lastMessageCreatedAt != null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatMessageTime(lastMessageCreatedAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatMeetingDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();

    final isToday =
        now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;

    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow =
        tomorrow.year == local.year &&
        tomorrow.month == local.month &&
        tomorrow.day == local.day;

    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    if (isToday) return '오늘 $time';
    if (isTomorrow) return '내일 $time';

    return '${local.month}/${local.day} $time';
  }

  static String _formatMessageTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
