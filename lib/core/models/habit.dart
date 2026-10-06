import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final String type;
  final String? feature;
  final String? notes;
  final String? reminderTime;
  final List<int> scheduledDays;
  final List<String> accountabilityContactIds;
  final List<String> completedDates;

  // Productivity
  final int? sessionLength;
  final int? focusLength;
  final int? breakLength;
  final int? cycles;

  // Fitness / Health / Custom
  final Map<String, dynamic>? details;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    this.feature,
    this.notes,
    this.reminderTime,
    this.scheduledDays = const [1, 2, 3, 4, 5, 6, 7],
    this.accountabilityContactIds = const [],
    this.completedDates = const [],
    this.sessionLength,
    this.focusLength,
    this.breakLength,
    this.cycles,
    this.details,
  });

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Habit(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Custom',
      feature: data['feature'],
      notes: data['notes'],
      reminderTime: data['reminderTime'],
      scheduledDays: List<int>.from(
        data['scheduledDays'] ?? [1, 2, 3, 4, 5, 6, 7],
      ),
      accountabilityContactIds: List<String>.from(
        data['accountabilityContactIds'] ?? [],
      ),
      completedDates: List<String>.from(data['completedDates'] ?? []),
      sessionLength: data['sessionLength'],
      focusLength: data['focusLength'],
      breakLength: data['breakLength'],
      cycles: data['cycles'],
      details: data['details'] == null
          ? null
          : Map<String, dynamic>.from(data['details']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'feature': feature,
      'notes': notes,
      'reminderTime': reminderTime,
      'scheduledDays': scheduledDays,
      'accountabilityContactIds': accountabilityContactIds,
      'completedDates': completedDates,
      'sessionLength': sessionLength,
      'focusLength': focusLength,
      'breakLength': breakLength,
      'cycles': cycles,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
