import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _initialized = false;
  bool _timezoneInitialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _requestPermission();

    if (!kIsWeb) {
      await _initializeLocalNotifications();
      await _initializeTimezone();
    }

    await _saveToken();

    _messaging.onTokenRefresh.listen(_saveTokenValue);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings: settings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized || kIsWeb) return;

    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.identifier),
    );

    _timezoneInitialized = true;
  }

  // Supports "18:45", "6:45 AM", and "6:45 PM".
  TimeOfDay? _parseReminderTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final text = value.trim();

    final amPmMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$',
    ).firstMatch(text);

    if (amPmMatch != null) {
      var hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();

      if (hour < 1 || hour > 12 || minute > 59) return null;

      if (period == 'AM') {
        hour = hour == 12 ? 0 : hour;
      } else {
        hour = hour == 12 ? 12 : hour + 12;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(text);

    if (match == null) return null;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Produces stable IDs so a habit's old reminders can be cancelled.
  int _notificationId(String habitId, int weekday) {
    var hash = 0;

    for (final codeUnit in habitId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x0FFFFFFF;
    }

    return hash * 8 + weekday;
  }

  Future<void> scheduleHabitReminders({
    required String habitId,
    required String habitName,
    required String? reminderTime,
    required List<int> scheduledDays,
  }) async {
    if (kIsWeb) return;

    await _initializeTimezone();

    // Remove previously scheduled reminders before rescheduling.
    await cancelHabitReminders(habitId);

    final time = _parseReminderTime(reminderTime);

    // A missing time or no selected days means no reminders.
    if (time == null || scheduledDays.isEmpty) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'again_habit_reminders',
        'Habit reminders',
        channelDescription: 'Reminders for your scheduled habits',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    for (final weekday in scheduledDays.toSet()) {
      if (weekday < DateTime.monday ||
          weekday > DateTime.sunday) {
        continue;
      }

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      final daysUntil =
          (weekday - scheduledDate.weekday + 7) % 7;

      scheduledDate = scheduledDate.add(
        Duration(days: daysUntil),
      );

      // If today's reminder time has passed, schedule next week.
      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(
          const Duration(days: 7),
        );
      }

      await _localNotifications.zonedSchedule(
        id: _notificationId(habitId, weekday),
        title: 'Time for $habitName',
        body: 'Open Again to mark your habit as complete.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelHabitReminders(String habitId) async {
    if (kIsWeb) return;

    for (var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++) {
      await _localNotifications.cancel(
        id: _notificationId(habitId, weekday),
      );
    }
  }

  // ----------------------------------------------------------
  // FIREBASE CLOUD MESSAGING
  // ----------------------------------------------------------

  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenValue(token);
      }
    } catch (_) {
      // Token registration might not be available yet.
    }
  }

  Future<void> _saveTokenValue(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _db.collection('users').doc(user.uid).set(
      {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _handleForegroundMessage(
    RemoteMessage message,
  ) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Again';

    final body =
        message.notification?.body ?? message.data['body'] ?? '';

    await saveNotification(
      title: title,
      body: body,
      type: message.data['type'] ?? 'general',
    );

    if (!kIsWeb) {
      await _showLocalNotification(title, body);
    }
  }

  Future<void> _handleOpenedMessage(
    RemoteMessage message,
  ) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Again';

    final body =
        message.notification?.body ?? message.data['body'] ?? '';

    await saveNotification(
      title: title,
      body: body,
      type: message.data['type'] ?? 'general',
    );
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'again_notifications',
      'Again Notifications',
      channelDescription: 'Notifications from Again',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(
            2147483647,
          ),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // ----------------------------------------------------------
  // FIRESTORE NOTIFICATIONS
  // ----------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _notifications(
    String uid,
  ) {
    return _db.collection('users').doc(uid).collection('notifications');
  }

  Stream<List<Map<String, dynamic>>> notificationStream(String uid) {
    return _notifications(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> saveNotification({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _notifications(user.uid).add({
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(
    String uid,
    String notificationId,
  ) async {
    await _notifications(uid)
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notifications(uid)
        .where('read', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(
    String uid,
    String notificationId,
  ) async {
    await _notifications(uid).doc(notificationId).delete();
  }
}