import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

class MeetingCreatePage extends StatelessWidget {
  const MeetingCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미팅 생성 더보기')),
      body: const Center(child: Text('미팅 생성 화면입니다')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
