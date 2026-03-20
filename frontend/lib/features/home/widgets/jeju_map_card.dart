import 'package:flutter/material.dart';
import '../models/region_summary_model.dart';

class JejuMapCard extends StatelessWidget {
  final List<RegionSummaryModel> summaries;
  final double screenHeight;

  const JejuMapCard({
    super.key,
    required this.screenHeight,
    required this.summaries,
  });

  static const Map<String, Offset> regionPositions = {
    '제주시/공항권': Offset(345, 78),
    '애월/한담권': Offset(95, 145),
    '협재/한림권': Offset(40, 215),
    '함덕/조천권': Offset(505, 90),
    '성산/우도권': Offset(690, 165),
    '표선/성읍권': Offset(525, 305),
    '중문/안덕권': Offset(175, 330),
    '서귀포시내권': Offset(285, 360),
  };

  @override
  Widget build(BuildContext context) {
    final mapHeight = screenHeight * 0.38;

    return Container(
      width: double.infinity,
      height: mapHeight,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widthRatio = constraints.maxWidth / 900;
          final heightRatio = constraints.maxHeight / 520;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Image.asset(
                    'assets/images/jeju.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ...summaries.map((item) {
                final position = regionPositions[item.regionPrimary];

                if (position == null) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: position.dx * widthRatio,
                  top: position.dy * heightRatio,
                  child: _SummaryBadge(text: item.summaryText),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String text;

  const _SummaryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffD9E1EC), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}
