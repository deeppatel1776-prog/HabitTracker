import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/achievement_badge_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  final LocalStorageService _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() async {
    final val = await _localStorage.getNotificationsEnabled();
    setState(() {
      _notificationsEnabled = val;
    });
  }

  void _toggleNotifications(bool val) async {
    setState(() {
      _notificationsEnabled = val;
    });
    await _localStorage.setNotificationsEnabled(val);
    if (!val) {
      await NotificationService().cancelAllNotifications();
    } else {
      ref.read(habitProvider.notifier).loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final habitState = ref.watch(habitProvider);
    final stats = ref.watch(statsProvider);
    final currentThemeMode = ref.watch(themeProvider);

    final user = authState.user;
    final userName = user?.name ?? 'User';
    final userEmail = user?.email ?? 'user@example.com';
    final joinedDateStr = user != null
        ? DateFormat('MMMM yyyy').format(user.createdAt)
        : 'August 2026';

    final unlockedCount = habitState.achievements
        .where((a) => a.isUnlocked)
        .length;

    ImageProvider? profileImageProvider;
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http://') ||
          user.photoUrl!.startsWith('https://')) {
        profileImageProvider = NetworkImage(user.photoUrl!);
      } else if (File(user.photoUrl!).existsSync()) {
        profileImageProvider = FileImage(File(user.photoUrl!));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => context.push('/habits/archived'),
            tooltip: 'Archived Habits',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: profileImageProvider,
                        child: profileImageProvider == null
                            ? Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Edit Profile',
                              onPressed: () => context.push('/profile/edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Joined $joinedDateStr",
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Summary Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    "${habitState.habits.length}",
                    "Total Habits",
                    Icons.track_changes_rounded,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    "$unlockedCount/${habitState.achievements.length}",
                    "Badges",
                    Icons.emoji_events_rounded,
                    const Color(0xFFFFBE0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    "${stats.currentMaxStreak}d",
                    "Max Streak",
                    Icons.local_fire_department_rounded,
                    const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settings & Preferences Card
            const Text(
              'Settings & Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: AppColors.textMuted.withOpacity(0.15),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Daily Habit Reminders',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Receive push notifications for task reminders & alerts',
                    ),
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                    activeColor: AppColors.primary,
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.notification_add_outlined,
                      color: AppColors.secondary,
                    ),
                    title: const Text(
                      'Test Reminder Notification',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Send immediate test reminder & alert popup'),
                    trailing: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onTap: () async {
                      await NotificationService().showInstantNotification(
                        id: 7777,
                        title: 'Task Reminder Demo 🎯',
                        body: 'Don\'t forget to complete your pending habits today!',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification sent! Check your status bar 🔔'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.archive_outlined,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Archived Habits',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Manage or restore inactive habits'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () => context.push('/habits/archived'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.palette_outlined,
                      color: AppColors.accent,
                    ),
                    title: const Text(
                      'App Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      currentThemeMode == ThemeMode.dark
                          ? 'Dark Mode Theme'
                          : currentThemeMode == ThemeMode.system
                              ? 'System Default Theme'
                              : 'Light Mode Theme',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentThemeMode == ThemeMode.dark
                            ? 'Dark 🌙'
                            : currentThemeMode == ThemeMode.system
                                ? 'System 💻'
                                : 'Light ☀️',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF319795),
                        ),
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select App Theme 🎨',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                                  title: const Text('Light Mode ☀️'),
                                  trailing: currentThemeMode == ThemeMode.light
                                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                                    Navigator.pop(ctx);
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.dark_mode_outlined, color: Colors.indigo),
                                  title: const Text('Dark Mode 🌙'),
                                  trailing: currentThemeMode == ThemeMode.dark
                                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                                    Navigator.pop(ctx);
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.settings_suggest_outlined, color: Colors.teal),
                                  title: const Text('System Default 💻'),
                                  trailing: currentThemeMode == ThemeMode.system
                                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Achievements Badge Grid Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements & Badges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "$unlockedCount of ${habitState.achievements.length} Unlocked",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Badges Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: habitState.achievements.length,
              itemBuilder: (context, index) {
                final achievement = habitState.achievements[index];
                return AchievementBadgeCard(achievement: achievement);
              },
            ),

            const SizedBox(height: 30),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                side: const BorderSide(color: AppColors.error, width: 1.5),
                foregroundColor: AppColors.error,
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Logout Account'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
