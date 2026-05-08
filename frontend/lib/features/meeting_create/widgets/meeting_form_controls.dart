import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class MeetingTimeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const MeetingTimeButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19, color: AppColors.gray600),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: AppColors.gray200, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: AppColors.gray50,
        ),
      ),
    );
  }
}

class MemberCountSelector extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final int minCount;

  const MemberCountSelector({
    super.key,
    required this.count,
    required this.onChanged,
    this.minCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gray200, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: count > minCount ? () => onChanged(count - 1) : null,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove, size: 20, color: Colors.black87),
            ),
            Text(
              '$count명',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(count + 1),
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 20, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
