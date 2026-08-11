import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/habit_card.dart';

class ArchivedHabitsScreen extends ConsumerWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    final archivedHabits = habitState.habits.where((h) => h.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Habits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: archivedHabits.isEmpty
          ? const EmptyStateWidget(
              title: 'No archived habits',
              message: 'Habits you archive will be moved here. You can restore them anytime.',
              icon: Icons.archive_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = archivedHabits[index];
                return HabitCard(habit: habit);
              },
            ),
    );
  }
}
