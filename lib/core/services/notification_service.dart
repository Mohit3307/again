import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _requestPermission();

    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }

    await _saveToken();

    _messaging.onTokenRefresh.listen(_saveTokenValue);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
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
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings: settings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenValue(token);
      }
    } catch (_) {
      // Notification permission/token may not be available yet.
    }
  }

  Future<void> _saveTokenValue(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    await _db.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Again';

    final body = message.notification?.body ?? message.data['body'] ?? '';

    await saveNotification(
      title: title,
      body: body,
      type: message.data['type'] ?? 'general',
    );

    if (!kIsWeb) {
      await _showLocalNotification(title, body);
    }
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Again';

    final body = message.notification?.body ?? message.data['body'] ?? '';

    await saveNotification(
      title: title,
      body: body,
      type: message.data['type'] ?? 'general',
    );
  }

  Future<void> _showLocalNotification(String title, String body) async {
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
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // ----------------------------------------------------------
  // FIRESTORE NOTIFICATIONS
  // ----------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _notifications(String uid) {
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

    if (user == null) {
      return;
    }

    await _notifications(user.uid).add({
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    await _notifications(uid).doc(notificationId).update({'read': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notifications(uid)
        .where('read', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _notifications(uid).doc(notificationId).delete();
  }
}
