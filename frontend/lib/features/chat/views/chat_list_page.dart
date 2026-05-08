import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../widgets/chat_room_card.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListViewModel>().getChatRoomList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatListViewModel>();
    final roomInfo = vm.chatRoomList ?? [];
    final unreadRoomCount = roomInfo
        .where((room) => room.unreadCount > 0)
        .length;

    Widget body;

    if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.errorMessage != null) {
      body = _ChatStateView(
        icon: Icons.error_outline,
        title: '채팅방을 불러오지 못했어요',
        message: vm.errorMessage!,
        actionLabel: '다시 시도',
        onAction: () {
          context.read<ChatListViewModel>().refreshChatRoomList();
        },
      );
    } else if (roomInfo.isEmpty) {
      body = const _ChatStateView(
        icon: Icons.chat_bubble_outline_rounded,
        title: '참여 중인 채팅방이 없어요',
        message: '동행에 참여하면 이곳에서 여행자들과 대화를 이어갈 수 있어요.',
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.brandTeal,
        onRefresh: () =>
            context.read<ChatListViewModel>().refreshChatRoomList(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          itemCount: roomInfo.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ChatListSummary(
                roomCount: roomInfo.length,
                unreadRoomCount: unreadRoomCount,
              );
            }

            final room = roomInfo[index - 1];

            return ChatRoomCard(
              title: room.meetingTitle,
              placeText: room.placeText,
              scheduledAt: room.scheduledAt,
              lastMessageContent: room.lastMessageContent,
              lastMessageCreatedAt: room.lastMessageCreatedAt,
              unreadCount: room.unreadCount,
              onTap: () async {
                final shouldRefresh = await Navigator.pushNamed(
                  context,
                  '/chatdetail',
                  arguments: room.meetingId,
                );

                if (!context.mounted) return;

                if (shouldRefresh == true) {
                  context.read<ChatListViewModel>().refreshChatRoomList();
                }
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        centerTitle: false,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: 25,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: body,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _ChatListSummary extends StatelessWidget {
  final int roomCount;
  final int unreadRoomCount;

  const _ChatListSummary({
    required this.roomCount,
    required this.unreadRoomCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brandMint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.brandTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$roomCount개의 채팅방',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unreadRoomCount > 0
                      ? '읽지 않은 대화가 있는 방 $unreadRoomCount개'
                      : '모든 대화를 확인했어요',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ChatStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandMint),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
