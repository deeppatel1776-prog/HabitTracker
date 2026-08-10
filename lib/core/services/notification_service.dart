import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/habit_model.dart';
import 'local_storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling FCM background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('TZ init error: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      // Request notification permissions for Android 13+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
      await initFirebaseMessaging();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> initFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title}');
        if (message.notification != null) {
          showInstantNotification(
            id: message.hashCode,
            title: message.notification?.title ?? 'Habit Notification',
            body: message.notification?.body ?? '',
            payload: message.data['payload'],
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM message opened app: ${message.data}');
      });

      _fcmToken = await messaging.getToken();
      debugPrint('Firebase FCM Push Token: $_fcmToken');
    } catch (e) {
      debugPrint('FirebaseMessaging init note: $e');
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    final enabled = await LocalStorageService().getNotificationsEnabled();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for daily habit reminders & completion',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF6C63FF),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitTitle,
    required TimeOfDay time,
  }) async {
    if (!_isInitialized) await init();

    final enabled = await LocalStorageService().getNotificationsEnabled();
    if (!enabled) return;

    final id = _getNotificationId(habitId);

    // Cancel existing reminder if any
    await cancelNotification(id);

    try {
      final nowLocal = DateTime.now();
      var scheduledDateTime = DateTime(
        nowLocal.year,
        nowLocal.month,
        nowLocal.day,
        time.hour,
        time.minute,
      );

      if (scheduledDateTime.isBefore(nowLocal)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'habit_reminders_channel',
        'Habit Reminders',
        channelDescription: 'Notifications for daily habit reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF6C63FF),
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        'Habit Reminder ⏰',
        'Time to complete your habit: "$habitTitle"!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'habit_$habitId',
      );

      debugPrint(
          'Scheduled daily reminder for $habitTitle at ${time.hour}:${time.minute}');
    } catch (e) {
      debugPrint('Error scheduling habit reminder: $e');
    }
  }

  /// Schedule daily evening reminder for uncompleted tasks (e.g. 8:00 PM)
  Future<void> syncUncompletedTasksReminder(List<HabitModel> habits) async {
    if (!_isInitialized) await init();

    final enabled = await LocalStorageService().getNotificationsEnabled();
    if (!enabled) return;

    const uncompletedChannelId = 99999;

    // Filter active habits for today
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final uncompleted = activeHabits.where((h) => !h.completedToday).toList();

    if (uncompleted.isEmpty) {
      // All done for today! Cancel pending warning notification
      await cancelNotification(uncompletedChannelId);
      return;
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      // Evening reminder at 8:00 PM (20:00)
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'uncompleted_habits_channel',
        'Uncompleted Tasks Reminder',
        channelDescription: 'Evening reminder for uncompleted daily tasks',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFFF6B6B),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final body = uncompleted.length == 1
          ? 'You still have 1 habit ("${uncompleted.first.title}") pending for today. Keep your streak alive! 🎯'
          : 'You have ${uncompleted.length} habits pending for today. Don\'t forget to finish them! 💪';

      await _notificationsPlugin.zonedSchedule(
        uncompletedChannelId,
        'Task Reminder: Pending Habits ⏰',
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'uncompleted_tasks',
      );
    } catch (e) {
      debugPrint('Error syncing uncompleted tasks reminder: $e');
    }
  }

  /// Show completion celebration notification
  Future<void> showCompletionNotification(String habitTitle, int streak) async {
    final streakMsg = streak > 1 ? ' 🔥 $streak-day streak!' : '';
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Habit Completed! 🎉',
      body: 'Awesome! You completed "$habitTitle"$streakMsg',
    );
  }

  /// Schedule countdown timer notification (for set timer feature)
  Future<void> scheduleTimerNotification({
    required int notificationId,
    required String habitTitle,
    required Duration duration,
  }) async {
    if (!_isInitialized) await init();

    final enabled = await LocalStorageService().getNotificationsEnabled();
    if (!enabled) return;

    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(duration);

      const androidDetails = AndroidNotificationDetails(
        'habit_timer_channel',
        'Habit Timer Alerts',
        channelDescription: 'Push notification alerts when a habit timer expires',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF6C63FF),
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '⏱️ Timer Finished!',
        'Time\'s up for "$habitTitle"! Great job finishing your session! 🎯',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'timer_finished',
      );
      debugPrint('Scheduled timer notification for $habitTitle in ${duration.inSeconds}s');
    } catch (e) {
      debugPrint('Error scheduling timer notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    await cancelNotification(_getNotificationId(habitId));
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  int _getNotificationId(String habitId) {
    return habitId.hashCode.abs() % 100000;
  }

  TimeOfDay? parseReminderTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final str = timeStr.trim().toUpperCase();
    try {
      if (str.contains('AM') || str.contains('PM')) {
        final parts = str.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (parts[1] == 'PM' && hour < 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      } else if (str.contains(':')) {
        final parts = str.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return null;
  }
}
