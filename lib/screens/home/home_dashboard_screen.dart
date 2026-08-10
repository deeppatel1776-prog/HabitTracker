import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_quotes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/filter_provider.dart';
import '../../models/habit_category.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/achievement_unlocked_dialog.dart';
import '../../core/utils/responsive_layout.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final habitState = ref.watch(habitProvider);
    final stats = ref.watch(statsProvider);
    final filterState = ref.watch(habitFilterProvider);
    final filteredHabits = ref.watch(filteredHabitsProvider);

    final userName = authState.user?.name ?? 'Friend';
    final user = authState.user;
    final dateString = DateFormat('EEEE, MMM d').format(DateTime.now());
    final dailyQuote = AppQuotes.getDailyQuote();

    ImageProvider? profileImageProvider;
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http://') ||
          user.photoUrl!.startsWith('https://')) {
        profileImageProvider = NetworkImage(user.photoUrl!);
      } else if (File(user.photoUrl!).existsSync()) {
        profileImageProvider = FileImage(File(user.photoUrl!));
      }
    }

    // Listen for newly unlocked achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || habitState.newlyUnlockedAchievement == null) {
        return;
      }
      final achievement = habitState.newlyUnlockedAchievement!;
      ref.read(habitProvider.notifier).dismissUnlockedAchievement();
      showDialog(
        context: context,
        builder: (_) => AchievementUnlockedDialog(
          achievement: achievement,
          onDismiss: () => Navigator.pop(context),
        ),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(habitProvider.notifier).loadData();
          },
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16.0 : 24.0,
                  vertical: isCompact ? 12.0 : 16.0,
                ),
                child: ResponsiveContent(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: User Greeting & Date
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 640;
                          return isCompact
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateString.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(
                                                'assets/images/logo.png',
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Hello, $userName! 👋",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () => context.push('/profile'),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: AppColors.primaryGradient,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: CircleAvatar(
                                              radius: 22,
                                              backgroundColor: AppColors.primary,
                                              backgroundImage: profileImageProvider,
                                              child: profileImageProvider == null
                                                  ? Text(
                                                      userName.isNotEmpty
                                                          ? userName[0].toUpperCase()
                                                          : 'U',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateString.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Hello, $userName! 👋",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push('/profile'),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.primaryGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: AppColors.primary,
                                            backgroundImage: profileImageProvider,
                                            child: profileImageProvider == null
                                                ? Text(
                                                    userName.isNotEmpty
                                                        ? userName[0].toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ).animate().fade().slideY(begin: -0.2, end: 0),

                      const SizedBox(height: 20),

                      // Circular Progress Ring
                      ProgressRing(
                        percentage: stats.dailyCompletionPercentage,
                      ).animate().fade(delay: 100.ms).scale(),

                      const SizedBox(height: 16),

                      // Streak Badges Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 640;
                          return isCompact
                              ? Column(
                                  children: [
                                    StreakBadge(
                                      streakCount: stats.currentMaxStreak,
                                      label: 'Current Streak',
                                      icon: Icons.local_fire_department_rounded,
                                      color: const Color(0xFFFF6B6B),
                                    ),
                                    const SizedBox(height: 12),
                                    StreakBadge(
                                      streakCount: stats.longestOverallStreak,
                                      label: 'Best Streak',
                                      icon: Icons.workspace_premium_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: StreakBadge(
                                        streakCount: stats.currentMaxStreak,
                                        label: 'Current Streak',
                                        icon:
                                            Icons.local_fire_department_rounded,
                                        color: const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StreakBadge(
                                        streakCount: stats.longestOverallStreak,
                                        label: 'Best Streak',
                                        icon: Icons.workspace_premium_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ).animate().fade(delay: 200.ms),

                      const SizedBox(height: 16),

                      // Motivational Quote Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.25),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 420;
                            return isCompact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.format_quote_rounded,
                                              color: Color(0xFF319795),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '"${dailyQuote.text}"',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontStyle: FontStyle.italic,
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "— ${dailyQuote.author}",
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(
                                            0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.format_quote_rounded,
                                          color: Color(0xFF319795),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '"${dailyQuote.text}"',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "— ${dailyQuote.author}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ).animate().fade(delay: 250.ms),

                      const SizedBox(height: 24),

                      // Search Bar & Filter Options
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textMuted.withOpacity(0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  ref
                                      .read(habitFilterProvider.notifier)
                                      .setSearchQuery(val);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search habits...',
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<HabitFilterStatus>(
                            icon: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textMuted.withOpacity(0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            onSelected: (status) {
                              ref
                                  .read(habitFilterProvider.notifier)
                                  .setFilterStatus(status);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: HabitFilterStatus.active,
                                child: Text('Active Habits'),
                              ),
                              const PopupMenuItem(
                                value: HabitFilterStatus.completed,
                                child: Text('Completed Today'),
                              ),
                              const PopupMenuItem(
                                value: HabitFilterStatus.all,
                                child: Text('All Habits'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Category Filter Chips Carousel
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(habitFilterProvider.notifier)
                                  .selectCategory(null);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: filterState.selectedCategory == null
                                    ? AppColors.primary
                                    : AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color: filterState.selectedCategory == null
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          ...HabitCategory.defaultCategories.map((category) {
                            final isSelected =
                                filterState.selectedCategory == category.name;
                            return CategoryChip(
                              category: category,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(habitFilterProvider.notifier)
                                    .selectCategory(category.name);
                              },
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Habits List Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            filterState.filterStatus ==
                                    HabitFilterStatus.completed
                                ? "Completed Today (${filteredHabits.length})"
                                : "Today's Habits (${filteredHabits.length})",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          PopupMenuButton<HabitSortOption>(
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.sort_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Sort",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            onSelected: (option) {
                              ref
                                  .read(habitFilterProvider.notifier)
                                  .setSortOption(option);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: HabitSortOption.newest,
                                child: Text('Newest First'),
                              ),
                              const PopupMenuItem(
                                value: HabitSortOption.streak,
                                child: Text('Highest Streak'),
                              ),
                              const PopupMenuItem(
                                value: HabitSortOption.name,
                                child: Text('By Name'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Habit Items List
                      if (filteredHabits.isEmpty) ...[
                        EmptyStateWidget(
                          title: 'No habits found',
                          message: filterState.searchQuery.isNotEmpty
                              ? 'No habits match "${filterState.searchQuery}". Try a different keyword.'
                              : 'You have no habits in this view yet. Tap + to build a new habit!',
                          icon: Icons.track_changes_rounded,
                          buttonText: 'Add First Habit',
                          onButtonPressed: () => context.push('/habit/add'),
                        ),
                      ] else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredHabits.length,
                          itemBuilder: (context, index) {
                            final habit = filteredHabits[index];
                            return HabitCard(habit: habit)
                                .animate()
                                .fade(delay: (index * 60).ms)
                                .slideY(begin: 0.1, end: 0);
                          },
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/habit/add');
        },
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Habit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ).animate().scale(delay: 400.ms),
    );
  }
}
