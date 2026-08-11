import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../models/habit_category.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final String? habitId;

  const AddEditHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Fitness';
  String _selectedFrequency = 'Daily';
  int _selectedColorValue = 0xFF6C63FF;
  String _selectedIcon = 'star';
  int _targetCount = 1;
  TimeOfDay? _reminderTime;
  bool _isInit = false;

  final List<int> _colorPalette = [
    0xFF6C63FF,
    0xFFFF6B6B,
    0xFF4ECDC4,
    0xFFA88BEB,
    0xFFFFBE0B,
    0xFF3A86FF,
    0xFF8338EC,
    0xFF06D6A0,
    0xFFFB5607,
    0xFFFF006E,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.habitId != null) {
      final habitState = ref.read(habitProvider);
      final habit = habitState.habits.firstWhere(
        (h) => h.id == widget.habitId,
        orElse: () => habitState.habits.first,
      );
      _titleController.text = habit.title;
      _descController.text = habit.description;
      _notesController.text = habit.notes;
      _selectedCategory = habit.category;
      _selectedFrequency = habit.frequency;
      _selectedColorValue = habit.colorValue;
      _selectedIcon = habit.icon;
      _targetCount = habit.targetCount;
      if (habit.reminderTime != null) {
        _reminderTime = NotificationService().parseReminderTime(habit.reminderTime);
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final reminderStr = _reminderTime != null
          ? "${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}"
          : null;

      if (widget.habitId != null) {
        final habitState = ref.read(habitProvider);
        final existing = habitState.habits.firstWhere((h) => h.id == widget.habitId);
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          icon: _selectedIcon,
          colorValue: _selectedColorValue,
          frequency: _selectedFrequency,
          reminderTime: reminderStr,
          targetCount: _targetCount,
          notes: _notesController.text.trim(),
        );
        await ref.read(habitProvider.notifier).updateHabit(updated);
      } else {
        await ref.read(habitProvider.notifier).addHabit(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              category: _selectedCategory,
              icon: _selectedIcon,
              colorValue: _selectedColorValue,
              frequency: _selectedFrequency,
              reminderTime: reminderStr,
              targetCount: _targetCount,
              notes: _notesController.text.trim(),
            );
      }

      if (mounted) {
        if (_reminderTime != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Daily reminder scheduled for ${_reminderTime!.format(context)} ⏰'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitId != null;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Habit' : 'Create New Habit'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Habit Title',
                hint: 'e.g. Read 20 Pages Daily',
                prefixIcon: Icons.edit_note_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a habit title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'e.g. Non-fiction books for self-improvement',
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 20),

              // Category Selector Grid
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitCategory.defaultCategories.map((cat) {
                  final isSel = _selectedCategory.toLowerCase() == cat.name.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat.name),
                    avatar: Icon(cat.icon, size: 16, color: isSel ? Colors.white : cat.color),
                    selected: isSel,
                    selectedColor: cat.color,
                    backgroundColor: isSel
                        ? cat.color
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF282834)
                            : cat.color.withOpacity(0.08)),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat.name;
                          _selectedColorValue = cat.color.toARGB32();
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Color Palette Picker
              Text(
                'Theme Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorPalette.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final colorVal = _colorPalette[idx];
                    final isSel = _selectedColorValue == colorVal;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorValue = colorVal;
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: Color(colorVal).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: isSel
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Frequency Selector
              Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['Daily', 'Weekly', 'Monthly'].map((freq) {
                  final isSel = _selectedFrequency == freq;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Center(child: Text(freq)),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: isSel
                            ? AppColors.primary
                            : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF282834)
                                : AppColors.inputBackground),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFrequency = freq;
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Reminder Time Picker
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Daily Reminder',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
                            );
                            if (time != null) {
                              setState(() {
                                _reminderTime = time;
                              });
                            }
                          },
                          child: Text(
                            _reminderTime == null
                                ? 'Set Time'
                                : _reminderTime!.format(context),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_reminderTime != null)
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
                            tooltip: 'Cancel / Remove Reminder',
                            onPressed: () {
                              setState(() {
                                _reminderTime = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              CustomTextField(
                controller: _notesController,
                label: 'Notes & Goal Motivation',
                hint: 'Why is this habit important to you?',
                prefixIcon: Icons.sticky_note_2_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              GradientButton(
                text: isEditing ? 'Update Habit' : 'Create Habit',
                onPressed: _onSave,
                icon: isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
