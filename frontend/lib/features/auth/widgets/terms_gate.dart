import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

import '../services/terms_storage.dart';
import '../views/terms_page.dart';

class TermsGate extends StatelessWidget {
  final Widget child;

  const TermsGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TermsStorage().hasAcceptedTerms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return child;
        }

        return const TermsPage();
      },
    );
  }
}
