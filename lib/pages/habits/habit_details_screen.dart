import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/contacts.dart';
import 'package:again/features/habits.dart';
import 'package:again/pages/habits/habit_edit_screen.dart';
import 'package:again/pages/habits/timer/habit_timer_screen.dart';

class HabitDetailsScreen extends ConsumerStatefulWidget {
  const HabitDetailsScreen({
    super.key,
    required this.uid,
    required this.habitId,
  });

  final String uid;
  final String habitId;

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    notesController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider(widget.uid));

    return habitsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (habits) {
        Habit? habit;

        for (final item in habits) {
          if (item.id == widget.habitId) {
            habit = item;
            break;
          }
        }

        if (habit == null) {
          return const Scaffold(body: Center(child: Text('Habit not found.')));
        }

        final currentHabit = habit;

        if (notesController.text != (currentHabit.notes ?? '')) {
          notesController.text = currentHabit.notes ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentHabit.name),
            actions: [
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HabitEditScreen(uid: widget.uid, habit: currentHabit),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: 'Type',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentHabit.type,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (currentHabit.feature != null) ...[
                      const SizedBox(height: 4),
                      Text(currentHabit.feature!),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _InfoCard(
                title: 'Schedule',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentHabit.reminderTime ?? 'No reminder time'),
                    const SizedBox(height: 8),
                    Text(_daysText(currentHabit.scheduledDays)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _StatsCard(habit: currentHabit),

              const SizedBox(height: 12),

              _InfoCard(
                title: 'Accountability',
                child: Consumer(
                  builder: (context, ref, _) {
                    final contacts = ref.watch(contactsProvider(widget.uid));

                    return contacts.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Could not load contacts.'),
                      data: (contactList) {
                        final selected = contactList.where(
                          (contact) => currentHabit.accountabilityContactIds
                              .contains(contact.id),
                        );

                        if (selected.isEmpty) {
                          return const Text('No accountability contacts.');
                        }

                        return Column(
                          children: [
                            for (final contact in selected)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(contact.name),
                                subtitle: Text(contact.email),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              if (currentHabit.type == 'Productivity')
                _InfoCard(
                  title: 'Productivity Timer',
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HabitTimerScreen(habit: currentHabit),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('Start Timer'),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              _InfoCard(
                title: 'Notes',
                child: Column(
                  children: [
                    TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Add notes...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final notes = notesController.text.trim();

                          await ref
                              .read(habitControllerProvider.notifier)
                              .updateNotes(
                                widget.uid,
                                currentHabit.id,
                                notes.isEmpty ? null : notes,
                              );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notes saved.')),
                          );
                        },
                        child: const Text('Save Notes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _daysText(List<int> days) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (days.isEmpty) {
      return 'No days selected';
    }

    return days.map((day) => names[day - 1]).join(', ');
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak(habit);
    final successRate = _calculateSuccessRate(habit);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department),
                  const SizedBox(height: 6),
                  Text(
                    '$streak',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Streak'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.trending_up),
                  const SizedBox(height: 6),
                  Text(
                    '$successRate%',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Success'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(Habit habit) {
    if (habit.scheduledDays.isEmpty) {
      return 0;
    }

    var streak = 0;
    var date = DateTime.now();

    if (!_isScheduled(date, habit) || !_isCompleted(date, habit)) {
      date = date.subtract(const Duration(days: 1));
    }

    for (var i = 0; i < 365; i++) {
      if (!_isScheduled(date, habit)) {
        date = date.subtract(const Duration(days: 1));
        continue;
      }

      if (!_isCompleted(date, habit)) {
        break;
      }

      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateSuccessRate(Habit habit) {
    var scheduled = 0;
    var completed = 0;

    final today = DateTime.now();

    for (var i = 1; i <= 30; i++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));

      if (!_isScheduled(date, habit)) {
        continue;
      }

      scheduled++;

      if (_isCompleted(date, habit)) {
        completed++;
      }
    }

    if (scheduled == 0) {
      return 0;
    }

    return ((completed / scheduled) * 100).round();
  }

  bool _isScheduled(DateTime date, Habit habit) {
    return habit.scheduledDays.contains(date.weekday);
  }

  bool _isCompleted(DateTime date, Habit habit) {
    final key =
        '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return habit.completedDates.contains(key);
  }
}
