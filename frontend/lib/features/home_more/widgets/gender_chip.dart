import 'package:flutter/material.dart';

class GenderChip extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderChip({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final genders = [
      {'label': '성별 무관', 'value': 'any'},
      {'label': '남성', 'value': 'male'},
      {'label': '여성', 'value': 'female'},
    ];

    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: genders.map((gender) {
        final label = gender['label']!;
        final value = gender['value']!;
        final isSelected = selectedGender == value;

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
              if (isSelected) {
                onChanged(null);
              } else {
                onChanged(value);
              }
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
