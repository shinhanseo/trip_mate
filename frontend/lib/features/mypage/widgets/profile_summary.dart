import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class UserProfileSummary extends StatelessWidget {
  final String nickname;
  final String gender;
  final String ageRange;
  final String? bio;
  final List<String>? favoriteTags;
  final String profileImage;

  const UserProfileSummary({
    super.key,
    required this.nickname,
    required this.gender,
    required this.ageRange,
    this.bio,
    this.favoriteTags,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.gray100,
          backgroundImage: profileImage.isNotEmpty
              ? NetworkImage(profileImage)
              : null,
          child: profileImage.isEmpty
              ? const Icon(Icons.person, color: AppColors.gray400)
              : null,
        ),
        const SizedBox(width: 25),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$ageRange / $gender',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              if (bio != null && bio!.trim().isNotEmpty) ...[
                Text(
                  bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (favoriteTags != null && favoriteTags!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: favoriteTags!
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.orange200),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileCountItem extends StatelessWidget {
  final int count;
  final String label;

  const ProfileCountItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralGray,
          ),
        ),
      ],
    );
  }
}
