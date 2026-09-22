import 'dart:async';

import 'package:again/core/models/habit.dart';
import 'package:again/core/services/habit_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits.g.dart';

@riverpod
HabitService habitService(Ref ref) {
  return HabitService();
}

@riverpod
Stream<List<Habit>> habits(Ref ref, String uid) {
  return ref.watch(habitServiceProvider).getHabits(uid);
}

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {}

  Future<void> addHabit(String uid, Habit habit) async {
    await ref.read(habitServiceProvider).addHabit(uid, habit);
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
  }
}
