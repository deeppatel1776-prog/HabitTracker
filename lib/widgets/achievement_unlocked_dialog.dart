import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement_model.dart';
import '../core/constants/app_colors.dart';
import 'gradient_button.dart';

class AchievementUnlockedDialog extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎉 ACHIEVEMENT UNLOCKED!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.primary,
              ),
            ).animate().fade().scale(duration: 400.ms),
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Icon(
                achievement.icon,
                size: 48,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut)
                .shimmer(delay: 800.ms, duration: 1000.ms),
            const SizedBox(height: 20),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: "Awesome!",
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
