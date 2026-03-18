import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: const Center(child: Text('홈화면입니다')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
