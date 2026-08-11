import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../core/constants/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double percentage;
  final double radius;
  final double lineWidth;
  final String title;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.radius = 65.0,
    this.lineWidth = 10.0,
    this.title = "Today's Progress",
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = (percentage / 100.0).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? const Color(0xFFA0A0B2) : AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? secondaryTextColor.withOpacity(0.15)
              : AppColors.textMuted.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: radius,
            lineWidth: lineWidth,
            animation: true,
            animationDuration: 1200,
            percent: clampedPercent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${percentage.toInt()}%",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            linearGradient: AppColors.primaryGradient,
            backgroundColor: isDark
                ? const Color(0xFF282834)
                : AppColors.inputBackground,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  percentage >= 100
                      ? "Awesome job! All daily habits completed! 🎉"
                      : percentage >= 50
                          ? "Great momentum! More than halfway there."
                          : "Keep going! Small steps lead to big wins.",
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
