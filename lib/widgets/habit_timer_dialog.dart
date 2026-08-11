import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/services/notification_service.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

class HabitTimerDialog extends ConsumerStatefulWidget {
  final HabitModel habit;

  const HabitTimerDialog({super.key, required this.habit});

  @override
  ConsumerState<HabitTimerDialog> createState() => _HabitTimerDialogState();
}

class _HabitTimerDialogState extends ConsumerState<HabitTimerDialog> {
  int _selectedMinutes = 5;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;
  final int _notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final List<int> _presetMinutes = [1, 5, 10, 15, 25, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectPreset(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _isFinished = false;
    });
  }

  void _startTimer() async {
    if (_remainingSeconds <= 0) return;

    setState(() {
      _isRunning = true;
      _isFinished = false;
    });

    // Schedule local push notification when timer hits zero
    await NotificationService().scheduleTimerNotification(
      notificationId: _notificationId,
      habitTitle: widget.habit.title,
      duration: Duration(seconds: _remainingSeconds),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isFinished = true;
        });
        _onTimerCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    NotificationService().cancelNotification(_notificationId);
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    NotificationService().cancelNotification(_notificationId);
    setState(() {
      _isRunning = false;
      _isFinished = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _onTimerCompleted() async {
    // Show instant notification if app is in foreground
    await NotificationService().showInstantNotification(
      id: _notificationId,
      title: '⏱️ Timer Finished!',
      body: 'Time\'s up for "${widget.habit.title}"! Great job! 🎉',
    );

    if (mounted) {
      // Auto mark habit complete option
      ref.read(habitProvider.notifier).toggleHabitCompletion(widget.habit.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Timer finished! "${widget.habit.title}" marked completed!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = Color(widget.habit.colorValue);
    final totalSeconds = _selectedMinutes * 60;
    final progress = totalSeconds > 0 ? (_remainingSeconds / totalSeconds) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Habit info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.timer_outlined, color: habitColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set Timer & Push Notification Alert 🔔',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Circular Timer Display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: habitColor.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isFinished ? AppColors.success : habitColor,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: _isFinished ? AppColors.success : Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isFinished
                        ? 'COMPLETED! 🎉'
                        : (_isRunning ? 'TIMER RUNNING ⏱️' : 'READY TO START'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isFinished
                          ? AppColors.success
                          : (_isRunning ? habitColor : AppColors.textMuted),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preset Buttons Row
          if (!_isRunning) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Timer Duration:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetMinutes.map((mins) {
                  final isSelected = _selectedMinutes == mins;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${mins}m${mins == 1 ? " (Test)" : ""}'),
                      selected: isSelected,
                      selectedColor: habitColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      backgroundColor: habitColor.withOpacity(0.08),
                      onSelected: (_) => _selectPreset(mins),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Control Buttons (Start / Pause / Reset)
          Row(
            children: [
              if (_isRunning)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pause', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: habitColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _remainingSeconds < _selectedMinutes * 60 ? 'Resume Timer' : 'Start Timer ⏱️',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _resetTimer,
                child: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
