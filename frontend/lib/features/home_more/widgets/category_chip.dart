import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const CategoryChip({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': '☕ 카페', 'value': 'cafe'},
      {'label': '🍜 식사', 'value': 'food'},
      {'label': '🏄 액티비티', 'value': 'activity'},
      {'label': '🍺 술', 'value': 'drink'},
      {'label': '🚗 관광', 'value': 'tour'},
    ];

    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: categories.map((category) {
        final value = category['value']!;
        final label = category['label']!;
        final isSelected = selectedCategory == value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: -1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              onChanged(isSelected ? null : value);
            },
            backgroundColor: const Color(0xffffffff),
            selectedColor: const Color(0xFFE8F0FE),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF93C5FD)
                    : const Color(0xffD1D5DB),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          ),
        );
      }).toList(),
    );
  }
}
