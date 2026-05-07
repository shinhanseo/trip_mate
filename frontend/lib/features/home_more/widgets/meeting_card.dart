import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../models/meeting_model.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onTap;

  const MeetingCard({super.key, required this.meeting, this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(meeting.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.gray200, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 7, color: categoryColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                meeting.title,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _categoryLabel(meeting.category),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meeting.regionPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  meeting.placeText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.neutralGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(meeting.scheduledAt),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.neutralGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MeetingTag(
                              text:
                                  '${meeting.currentMembers}/${meeting.maxMembers}명',
                              backgroundColor: AppColors.slate100,
                              textColor: AppColors.slate500,
                            ),
                            _MeetingTag(
                              text: _genderLabel(meeting.gender),
                              backgroundColor: AppColors.success50,
                              textColor: AppColors.success700,
                            ),
                            _MeetingTag(
                              text: _ageGroupLabel(meeting.ageGroups),
                              backgroundColor: AppColors.indigo50,
                              textColor: AppColors.indigo700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'food':
        return Colors.deepOrange;
      case 'cafe':
        return Colors.brown;
      case 'drink':
        return Colors.amber;
      case 'activity':
        return AppColors.brandTeal;
      case 'tour':
        return Colors.blueAccent;
      default:
        return AppColors.brandMint;
    }
  }

  static String _formatDateTime(DateTime dateTime) {
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

    if (isToday) return '당일 $time';
    if (isTomorrow) return '내일 $time';

    return '${local.month}/${local.day} $time';
  }

  static String _genderLabel(String gender) {
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      default:
        return '성별 무관';
    }
  }

  static String _ageGroupLabel(List<String> ageGroups) {
    if (ageGroups.isEmpty || ageGroups.contains('any')) {
      return '연령 무관';
    }

    final mapped = ageGroups.map((age) {
      if (age.endsWith('s')) {
        return '${age.replaceAll('s', '')}대';
      }
      return age;
    }).toList();

    return mapped.join(' · ');
  }

  static String _categoryLabel(String category) {
    switch (category) {
      case 'food':
        return '🍜 식사';
      case 'cafe':
        return '☕ 카페';
      case 'drink':
        return '🍺 술';
      case 'activity':
        return '🏄 액티비티';
      case 'tour':
        return '🚗 관광';
      default:
        return category;
    }
  }
}

class _MeetingTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _MeetingTag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
