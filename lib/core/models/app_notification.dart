import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool read;
  final String? type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.read = false,
    this.type,
  });

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final timestamp = data['createdAt'];

    return AppNotification(
      id: doc.id,
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      read: data['read'] ?? false,
      type: data['type'],
    );
  }
}
