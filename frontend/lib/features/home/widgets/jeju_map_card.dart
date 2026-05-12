import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../models/region_summary_model.dart';

class JejuMapCard extends StatelessWidget {
  final List<RegionSummaryModel> summaries;
  final double screenHeight;

  const JejuMapCard({
    super.key,
    required this.screenHeight,
    required this.summaries,
  });

  static const Map<String, Offset> regionFractions = {
    '제주시/공항권': Offset(0.45, 0.25),
    '애월/한담권': Offset(0.17, 0.36),
    '협재/한림권': Offset(0.04, 0.55),
    '함덕/조천권': Offset(0.73, 0.21),
    '성산/우도권': Offset(0.80, 0.41),
    '표선/성읍권': Offset(0.70, 0.59),
    '중문/안덕권': Offset(0.20, 0.71),
    '서귀포시내권': Offset(0.49, 0.68),
  };

  @override
  Widget build(BuildContext context) {
    final mapHeight = screenHeight * 0.38;

    return Container(
      width: double.infinity,
      height: mapHeight,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.mint.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlueGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/jeju.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ...summaries.map((item) {
                final fraction = regionFractions[item.regionPrimary];

                if (fraction == null) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: constraints.maxWidth * fraction.dx,
                  top: constraints.maxHeight * fraction.dy,
                  child: Transform.translate(
                    offset: const Offset(-24, -14),
                    child: _SummaryBadge(text: item.summaryText),
                  ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.brandMint.withValues(alpha: 0.55),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  text,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
