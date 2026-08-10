import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/home/home_dashboard_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/habits/add_edit_habit_screen.dart';
import '../../screens/habits/habit_detail_screen.dart';
import '../../screens/habits/archived_habits_screen.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to rebuild router when auth changes
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/profile/edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/habit/add',
        builder: (context, state) => const AddEditHabitScreen(),
      ),
      GoRoute(
        path: '/habit/edit/:id',
        builder: (context, state) {
          final habitId = state.pathParameters['id'];
          return AddEditHabitScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/habit/detail/:id',
        builder: (context, state) {
          final habitId = state.pathParameters['id'] ?? '';
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/habits/archived',
        builder: (context, state) => const ArchivedHabitsScreen(),
      ),
    ],
  );
});
