import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../../auth/viewmodels/auth_state.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_detail_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';

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
    final currentUserId = context.watch<AuthState>().currentUser?.id;

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
        centerTitle: true,
        title: Text(
          meeting.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              Text(
                meeting.placeText,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDateTime(meeting.scheduledAt),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${meeting.currentMembers}/${meeting.maxMembers}명',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.gray200, thickness: 1, height: 1),

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      '아직 메시지가 없습니다.',
                      style: TextStyle(fontSize: 15, color: AppColors.gray400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message.senderId == currentUserId;
                      final previousMessage = index > 0
                          ? messages[index - 1]
                          : null;
                      final showProfileImage =
                          !isMine &&
                          previousMessage?.senderId != message.senderId;
                      return ChatMessageBubble(
                        message: message,
                        isMine: isMine,
                        showProfileImage: showProfileImage,
                      );
                    },
                  ),
          ),

          SafeArea(
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
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
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
                    width: 44,
                    height: 44,
                    child: FilledButton(
                      onPressed: () {
                        final content = _messageController.text;
                        context.read<ChatDetailViewModel>().sendMessage(
                          meetingId: widget.meetingId,
                          content: content,
                        );

                        _messageController.clear();
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.brandMint,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    return '${local.month}/${local.day} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
