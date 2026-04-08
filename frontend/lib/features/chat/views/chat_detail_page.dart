import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_detail_viewmodel.dart';

class ChatDetailPage extends StatefulWidget {
  final int meetingId;

  const ChatDetailPage({super.key, required this.meetingId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatDetailViewModel>().getChatDetail(widget.meetingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatDetailViewModel>();
    final meeting = vm.chatDetail?.meeting;
    final messages = vm.chatDetail?.messages;

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(body: Center(child: Text(vm.errorMessage!)));
    }

    return const Scaffold(backgroundColor: const Color(0xffffffff));
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
