import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채팅')),
      body: const Center(child: Text('채팅화면입니다')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
