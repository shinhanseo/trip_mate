import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: const Center(child: Text('마이페이지 화면입니다')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
