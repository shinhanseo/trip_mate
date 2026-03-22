import 'package:flutter/material.dart';

class AgeGroupChip extends StatelessWidget {
  final String? selectedAgeGroup;
  final ValueChanged<String?> onChanged;

  const AgeGroupChip({
    super.key,
    required this.selectedAgeGroup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> ageGroups = ['연령 무관', '20대', '30대', '40대', '50대'];

    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: ageGroups.map((ageGroup) {
        final isSelected = selectedAgeGroup == ageGroup;

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
              ageGroup,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (isSelected) {
                onChanged(null);
              } else {
                onChanged(ageGroup);
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
