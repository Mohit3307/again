import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:again/core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final notificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
      return ref.watch(notificationServiceProvider).notificationStream(uid);
    });
