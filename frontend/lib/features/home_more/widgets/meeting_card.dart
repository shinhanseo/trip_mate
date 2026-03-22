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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 24),
              const SizedBox(width: 4),
              Text(
                meeting.regionPrimary,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff8D8D8D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.access_time, size: 24),
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MeetingTag(
                text: '${meeting.currentMembers}/${meeting.maxMembers}명',
                backgroundColor: const Color(0xffEEF3F8),
                textColor: const Color(0xff667085),
              ),
              _MeetingTag(
                text: _genderLabel(meeting.gender),
                backgroundColor: const Color(0xffEAF7F3),
                textColor: const Color(0xff4D7C73),
              ),
              _MeetingTag(
                text: _ageGroupLabel(meeting.ageGroups),
                backgroundColor: const Color(0xffECF2FF),
                textColor: const Color(0xff4E6BB2),
              ),
              _MeetingTag(
                text: _categoryLabel(meeting.category),
                backgroundColor: const Color(0xffFFF4E8),
                textColor: const Color(0xffA36A2B),
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

    return mapped.join(',');
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
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
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
