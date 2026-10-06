import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/habits.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider(uid));

    return habitsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (habits) {
        if (habits.isEmpty) {
          return const Center(
            child: Text('Create some habits to see your stats.'),
          );
        }

        final stats = _StatsCalculator(habits);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            const Text(
              'Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            // -------------------------------------------------
            // OVERVIEW
            // -------------------------------------------------
            const Text('overview', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(label: 'habits', value: '${habits.length}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'longest streak',
                    value: '${stats.longestStreak}d',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'this week',
                    value: '${stats.thisWeekPercentage}%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // -------------------------------------------------
            // BY CATEGORY
            // -------------------------------------------------
            const Text('by category', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            _CategoryCard(
              title: 'Productivity',
              value: _categoryValue(stats.categoryPercentage('Productivity')),
            ),

            const SizedBox(height: 8),

            _CategoryCard(
              title: 'Fitness',
              value: _categoryValue(stats.categoryPercentage('Fitness')),
            ),

            const SizedBox(height: 8),

            _CategoryCard(title: 'Health', value: stats.healthStatus),

            const SizedBox(height: 28),

            // -------------------------------------------------
            // PER HABIT
            // -------------------------------------------------
            const Text('per habit', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            for (final habit in habits) ...[
              _HabitStatsCard(
                habit: habit,
                streak: stats.currentStreak(habit),
                success: stats.habitPercentage(habit),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  String _categoryValue(int? value) {
    if (value == null) {
      return '—';
    }

    return '$value%';
  }
}

// =============================================================
// STATS CALCULATOR
// =============================================================

class _StatsCalculator {
  _StatsCalculator(this.habits);

  final List<Habit> habits;

  // -----------------------------------------------------------
  // LONGEST STREAK
  // -----------------------------------------------------------

  int get longestStreak {
    var longest = 0;

    for (final habit in habits) {
      final streak = _longestStreak(habit);

      if (streak > longest) {
        longest = streak;
      }
    }

    return longest;
  }

  // -----------------------------------------------------------
  // THIS WEEK
  // -----------------------------------------------------------

  int get thisWeekPercentage {
    final today = _dateOnly(DateTime.now());

    // Sunday of current week.
    final sunday = today.subtract(Duration(days: today.weekday % 7));

    var scheduled = 0;
    var completed = 0;

    for (var i = 0; i <= today.difference(sunday).inDays; i++) {
      final date = sunday.add(Duration(days: i));

      for (final habit in habits) {
        // Not scheduled = rest day.
        if (!habit.scheduledDays.contains(date.weekday)) {
          continue;
        }

        scheduled++;

        if (_isCompleted(habit, date)) {
          completed++;
        }
      }
    }

    if (scheduled == 0) {
      return 0;
    }

    return ((completed / scheduled) * 100).round();
  }

  // -----------------------------------------------------------
  // CATEGORY PERCENTAGE
  // -----------------------------------------------------------

  int? categoryPercentage(String category) {
    final categoryHabits = habits
        .where((habit) => habit.type == category)
        .toList();

    if (categoryHabits.isEmpty) {
      return null;
    }

    return _percentageForHabits(categoryHabits);
  }

  // -----------------------------------------------------------
  // HEALTH STATUS
  // -----------------------------------------------------------

  String get healthStatus {
    final healthHabits = habits
        .where((habit) => habit.type == 'Health')
        .toList();

    if (healthHabits.isEmpty) {
      return '—';
    }

    final percentage = _percentageForHabits(healthHabits);

    if (percentage >= 70) {
      return 'on track';
    }

    return '$percentage%';
  }

  // -----------------------------------------------------------
  // PER-HABIT SUCCESS
  // -----------------------------------------------------------

  int habitPercentage(Habit habit) {
    final today = _dateOnly(DateTime.now());

    // Last 30 days.
    final start = today.subtract(const Duration(days: 29));

    var scheduled = 0;
    var completed = 0;

    for (var i = 0; i < 30; i++) {
      final date = start.add(Duration(days: i));

      if (!habit.scheduledDays.contains(date.weekday)) {
        continue;
      }

      scheduled++;

      if (_isCompleted(habit, date)) {
        completed++;
      }
    }

    if (scheduled == 0) {
      return 0;
    }

    return ((completed / scheduled) * 100).round();
  }

  // -----------------------------------------------------------
  // CURRENT STREAK
  // -----------------------------------------------------------

  int currentStreak(Habit habit) {
    final today = _dateOnly(DateTime.now());

    var date = today;
    var streak = 0;

    // If today's habit is scheduled but not completed,
    // don't immediately destroy yesterday's streak.
    if (habit.scheduledDays.contains(date.weekday) &&
        !_isCompleted(habit, date)) {
      date = date.subtract(const Duration(days: 1));
    }

    for (var i = 0; i < 3650; i++) {
      // Rest day - skip it.
      if (!habit.scheduledDays.contains(date.weekday)) {
        date = date.subtract(const Duration(days: 1));
        continue;
      }

      if (_isCompleted(habit, date)) {
        streak++;
      } else {
        break;
      }

      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // -----------------------------------------------------------
  // LONGEST STREAK FOR ONE HABIT
  // -----------------------------------------------------------

  int _longestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) {
      return 0;
    }

    final completed = habit.completedDates
        .map((value) => DateTime.tryParse(value))
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();

    if (completed.isEmpty) {
      return 0;
    }

    final first = completed.reduce((a, b) => a.isBefore(b) ? a : b);

    final last = completed.reduce((a, b) => a.isAfter(b) ? a : b);

    var streak = 0;
    var longest = 0;

    for (
      var date = first;
      !date.isAfter(last);
      date = date.add(const Duration(days: 1))
    ) {
      // Rest day doesn't break streak.
      if (!habit.scheduledDays.contains(date.weekday)) {
        continue;
      }

      if (_isCompleted(habit, date)) {
        streak++;

        if (streak > longest) {
          longest = streak;
        }
      } else {
        streak = 0;
      }
    }

    return longest;
  }

  // -----------------------------------------------------------
  // MULTIPLE HABITS PERCENTAGE
  // -----------------------------------------------------------

  int _percentageForHabits(List<Habit> habitList) {
    final today = _dateOnly(DateTime.now());

    final start = today.subtract(const Duration(days: 29));

    var scheduled = 0;
    var completed = 0;

    for (final habit in habitList) {
      for (var i = 0; i < 30; i++) {
        final date = start.add(Duration(days: i));

        if (!habit.scheduledDays.contains(date.weekday)) {
          continue;
        }

        scheduled++;

        if (_isCompleted(habit, date)) {
          completed++;
        }
      }
    }

    if (scheduled == 0) {
      return 0;
    }

    return ((completed / scheduled) * 100).round();
  }

  // -----------------------------------------------------------
  // HELPERS
  // -----------------------------------------------------------

  bool _isCompleted(Habit habit, DateTime date) {
    return habit.completedDates.contains(_dateKey(date));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

// =============================================================
// STAT CARD
// =============================================================

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

// =============================================================
// CATEGORY CARD
// =============================================================

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value),
        ],
      ),
    );
  }
}

// =============================================================
// HABIT CARD
// =============================================================

class _HabitStatsCard extends StatelessWidget {
  const _HabitStatsCard({
    required this.habit,
    required this.streak,
    required this.success,
  });

  final Habit habit;
  final int streak;
  final int success;

  @override
  Widget build(BuildContext context) {
    String subtitle;

    if (habit.type == 'Health') {
      final duration = habit.details?['duration'];

      if (duration != null) {
        subtitle = '$duration · $success% success';
      } else {
        subtitle = '$success% success';
      }
    } else {
      subtitle = 'Streak ${streak}d · $success% success';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
