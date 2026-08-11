import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StreakBadge extends StatelessWidget {
  final int streakCount;
  final String label;
  final IconData icon;
  final Color color;

  const StreakBadge({
    super.key,
    required this.streakCount,
    required this.label,
    this.icon = Icons.local_fire_department_rounded,
    this.color = const Color(0xFFFF6B6B),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? const Color(0xFFA0A0B2) : AppColors.textSecondary);

    final displayValue = label.contains('Streak')
        ? "$streakCount Days"
        : (label.contains('%') ? "$streakCount%" : "$streakCount Active");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.18) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? color.withOpacity(0.35) : color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.25) : color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
