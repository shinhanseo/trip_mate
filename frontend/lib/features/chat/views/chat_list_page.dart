import 'package:flutter/material.dart';
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

    Widget body;

    if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.errorMessage != null) {
      body = Center(child: Text(vm.errorMessage!));
    } else if (roomInfo.isEmpty) {
      body = const Center(child: Text('참여 중인 채팅방이 없습니다.'));
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: roomInfo.length,
        itemBuilder: (context, index) {
          final room = roomInfo[index];

          return ChatRoomCard(
            title: room.meetingTitle,
            placeText: room.placeText,
            scheduledAt: room.scheduledAt,
            lastMessageContent: room.lastMessageContent,
            lastMessageCreatedAt: room.lastMessageCreatedAt,
            onTap: () {
              // 채팅 상세 이동
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        title: const Text('채팅'),
      ),
      body: body,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
