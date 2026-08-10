import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievement_model.dart';
import '../core/constants/app_colors.dart';

class AchievementBadgeCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadgeCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Colors.white
            : AppColors.inputBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.textMuted.withOpacity(0.1),
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.textMuted.withOpacity(0.1),
            ),
            child: Icon(
              achievement.icon,
              size: 32,
              color: achievement.isUnlocked
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: achievement.isUnlocked
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Unlocked ${DateFormat('MMM d').format(achievement.unlockedAt!)}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
