import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../../auth/viewmodels/auth_state.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_detail_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_system_message.dart';

class ChatDetailPage extends StatefulWidget {
  final int meetingId;

  const ChatDetailPage({super.key, required this.meetingId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(_handleDraftChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatDetailViewModel>().getChatDetail(widget.meetingId);
    });
  }

  void _handleDraftChanged() {
    final hasDraft = _messageController.text.trim().isNotEmpty;
    if (hasDraft == _hasDraft) return;

    setState(() {
      _hasDraft = hasDraft;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleDraftChanged);
    _messageController.dispose();
    _scrollController.dispose();
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
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
        ),
        body: _ChatDetailStateView(
          icon: Icons.error_outline,
          title: '채팅방을 불러오지 못했어요',
          message: vm.errorMessage!,
        ),
      );
    }

    final detail = vm.chatDetail;

    if (detail == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: _ChatDetailStateView(
          icon: Icons.chat_bubble_outline_rounded,
          title: '채팅방을 찾을 수 없어요',
          message: '동행 참여 상태를 다시 확인해주세요.',
        ),
      );
    }

    final meeting = detail.meeting;
    final messages = detail.messages;
    final messageCount = messages.length;

    if (messageCount != _lastMessageCount) {
      final shouldAnimate = _lastMessageCount > 0;
      _lastMessageCount = messageCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: shouldAnimate);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          meeting.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.black),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/meetingdetail',
                arguments: widget.meetingId,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          _ChatMeetingMeta(
            placeText: meeting.placeText,
            scheduledAt: _formatDateTime(meeting.scheduledAt),
            memberText: '${meeting.currentMembers}/${meeting.maxMembers}명',
          ),
          const Divider(color: AppColors.gray200, thickness: 1, height: 1),

          Expanded(
            child: messages.isEmpty
                ? const _ChatDetailStateView(
                    icon: Icons.forum_outlined,
                    title: '아직 메시지가 없어요',
                    message: '첫 메시지를 보내 동행 대화를 시작해보세요.',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      if (message.type == 'system') {
                        return ChatSystemMessage(content: message.content);
                      }
                      final isMine = message.senderId == currentUserId;
                      final previousMessage = index > 0
                          ? messages[index - 1]
                          : null;
                      final showProfileImageAndNickname =
                          !isMine &&
                          previousMessage?.senderId != message.senderId;
                      return ChatMessageBubble(
                        message: message,
                        isMine: isMine,
                        showProfileImageAndNickname:
                            showProfileImageAndNickname,
                      );
                    },
                  ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(top: BorderSide(color: AppColors.gray200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: const TextStyle(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: AppColors.gray50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.gray200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.gray200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.brandMint,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: FilledButton(
                      onPressed: _hasDraft
                          ? () {
                              final content = _messageController.text;
                              context.read<ChatDetailViewModel>().sendMessage(
                                meetingId: widget.meetingId,
                                content: content,
                              );

                              _messageController.clear();
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: _hasDraft
                            ? AppColors.brandMint
                            : AppColors.gray300,
                        disabledBackgroundColor: AppColors.gray300,
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

  void _scrollToBottom({required bool animated}) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.maxScrollExtent;

    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }

    _scrollController.jumpTo(position);
  }
}

class _ChatMeetingMeta extends StatelessWidget {
  final String placeText;
  final String scheduledAt;
  final String memberText;

  const _ChatMeetingMeta({
    required this.placeText,
    required this.scheduledAt,
    required this.memberText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(icon: Icons.location_on_outlined, text: placeText),
            _MetaChip(icon: Icons.access_time, text: scheduledAt),
            _MetaChip(icon: Icons.people_alt_outlined, text: memberText),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.gray500),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatDetailStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ChatDetailStateView({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 30, color: AppColors.gray500),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
