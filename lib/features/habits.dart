import 'dart:async';

import 'package:again/core/models/habit.dart';
import 'package:again/core/services/habit_service.dart';
import 'package:again/core/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits.g.dart';

@riverpod
HabitService habitService(Ref ref) => HabitService();

@riverpod
Stream<List<Habit>> habits(Ref ref, String uid) {
  return ref.watch(habitServiceProvider).getHabits(uid);
}

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {}

  Future<void> addHabit(String uid, Habit habit) async {
    final id = await ref.read(habitServiceProvider).addHabit(uid, habit);

    await NotificationService.instance.scheduleHabitReminders(
      habitId: id,
      habitName: habit.name,
      reminderTime: habit.reminderTime,
      scheduledDays: habit.scheduledDays,
    );
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    await ref.read(habitServiceProvider).updateHabit(uid, habit);

    await NotificationService.instance.scheduleHabitReminders(
      habitId: habit.id,
      habitName: habit.name,
      reminderTime: habit.reminderTime,
      scheduledDays: habit.scheduledDays,
    );
  }

  Future<void> updateNotes(
    String uid,
    String habitId,
    String? notes,
  ) async {
    await ref
        .read(habitServiceProvider)
        .updateNotes(uid, habitId, notes);
  }

  Future<void> toggleHabit(
    String uid,
    String habitId,
    String date,
    bool completed,
  ) async {
    await ref
        .read(habitServiceProvider)
        .toggleHabit(uid, habitId, date, completed);
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await ref.read(habitServiceProvider).deleteHabit(uid, habitId);

    await NotificationService.instance.cancelHabitReminders(habitId);
  }
}