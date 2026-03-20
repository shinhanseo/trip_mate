import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

class HomeMorePage extends StatelessWidget {
  const HomeMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈화면 더보기')),
      body: const Center(child: Text('홈화면 더보기 화면입니다')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
