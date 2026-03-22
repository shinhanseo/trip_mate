import 'package:flutter/material.dart';
import '../models/meeting_model.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;

  const MeetingCard({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meeting.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meeting.regionPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff9CA3AF),
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
                    size: 22,
                    color: Color(0xff6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    meeting.placeText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff8D8D8D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 22,
                    color: Color(0xff6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(meeting.scheduledAt),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff8D8D8D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MeetingTag(
                text: '${meeting.currentMembers}/${meeting.maxMembers}명',
                backgroundColor: const Color(0xffF1F5F9),
                textColor: const Color(0xff64748B),
              ),
              _MeetingTag(
                text: _genderLabel(meeting.gender),
                backgroundColor: const Color(0xffECFDF5),
                textColor: const Color(0xff047857),
              ),
              _MeetingTag(
                text: _ageGroupLabel(meeting.ageGroups),
                backgroundColor: const Color(0xffEEF2FF),
                textColor: const Color(0xff4338CA),
              ),
              _MeetingTag(
                text: _categoryLabel(meeting.category),
                backgroundColor: const Color(0xffFFF7ED),
                textColor: const Color(0xffC2410C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
