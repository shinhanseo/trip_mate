import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../auth/viewmodels/auth_state.dart';
import '../models/chat_detail_model.dart';
import '../viewmodels/chat_detail_viewmodel.dart';

class ChatDetailPage extends StatefulWidget {
  final int meetingId;

  const ChatDetailPage({super.key, required this.meetingId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatDetailViewModel>().getChatDetail(widget.meetingId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatDetailViewModel>();
    final currentUserId = context.select<AuthState, int?>(
      (auth) => auth.currentUser?.id,
    );

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(body: Center(child: Text(vm.errorMessage!)));
    }

    final detail = vm.chatDetail;

    if (detail == null) {
      return const Scaffold(body: Center(child: Text('채팅방을 찾을 수 없습니다.')));
    }

    final meeting = detail.meeting;
    final messages = detail.messages;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: Text(
          meeting.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          _MeetingHeader(meeting: meeting),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      '아직 메시지가 없습니다.',
                      style: TextStyle(color: AppColors.gray400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine =
                          currentUserId != null &&
                          message.senderId == currentUserId;

                      return _MessageBubble(
                        message: message,
                        isMine: isMine,
                        timeText: _formatMessageTime(message.createdAt),
                      );
                    },
                  ),
          ),
          _MessageInput(controller: _messageController),
        ],
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

class _MeetingHeader extends StatelessWidget {
  final MeetingModel meeting;

  const _MeetingHeader({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meeting.placeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                _ChatDetailPageState._formatMeetingDateTime(
                  meeting.scheduledAt,
                ),
                style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.people_alt_outlined,
                size: 16,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 4),
              Text(
                '${meeting.currentMembers}/${meeting.maxMembers}',
                style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final String timeText;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _ProfileAvatar(imageUrl: message.senderProfileImageUrl),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMine)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      message.senderNickname ?? '알 수 없음',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isMine) _MessageTime(timeText),
                    if (isMine) const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppColors.brandMint
                              : AppColors.gray100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMine ? 16 : 4),
                            bottomRight: Radius.circular(isMine ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isMine ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    if (!isMine) const SizedBox(width: 6),
                    if (!isMine) _MessageTime(timeText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.gray100,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? const Icon(Icons.person, size: 18, color: AppColors.gray400)
          : null,
    );
  }
}

class _MessageTime extends StatelessWidget {
  final String text;

  const _MessageTime(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: AppColors.gray400),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;

  const _MessageInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: const TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 42,
              height: 42,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.brandMint,
                  shape: const CircleBorder(),
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 22,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
