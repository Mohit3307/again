import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/habits.dart';
import 'package:again/pages/habits/select_habit_type_screen.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final habits =
        ref.watch(habitsProvider(uid));

    return habits.when(
      loading: () =>
          const Center(
        child:
            CircularProgressIndicator(),
      ),

      error: (
        error,
        stackTrace,
      ) =>
          Center(
        child:
            Text('Error: $error'),
      ),

      data: (habits) =>
          ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          90,
        ),

        children: [
          Text(
            'Habits',
            style:
                Theme.of(context)
                    .textTheme
                    .headlineSmall,
          ),

          const SizedBox(height: 16),

          const _WeekHeader(),

          const SizedBox(height: 4),

          for (final habit in habits)
            _HabitRow(
              habit: habit,
              uid: uid,
            ),

          if (habits.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.all(32),
              child: Center(
                child:
                    Text(
                  'No habits yet.',
                ),
              ),
            ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const SelectHabitTypeScreen(),
                ),
              );
            },
            child:
                const Text(
              'Add Habit',
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekHeader
    extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(
    BuildContext context,
  ) {
    const days = [
      'SU',
      'MO',
      'TU',
      'WE',
      'TH',
      'FR',
      'SA',
    ];

    return Row(
      children: [
        const SizedBox(
          width: 120,
        ),

        for (final day in days)
          Expanded(
            child: Center(
              child: Text(
                day,
                style:
                    Theme.of(context)
                        .textTheme
                        .labelSmall,
              ),
            ),
          ),

        const SizedBox(
          width: 40,
        ),
      ],
    );
  }
}

class _HabitRow
    extends ConsumerWidget {
  const _HabitRow({
    required this.habit,
    required this.uid,
  });

  final Habit habit;
  final String uid;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final now =
        DateTime.now();

    final sunday =
        now.subtract(
      Duration(
        days: now.weekday % 7,
      ),
    );

    return SizedBox(
      height: 42,

      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              habit.name.isEmpty
                  ? 'Unnamed habit'
                  : habit.name,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),

          for (var i = 0;
              i < 7;
              i++)
            Expanded(
              child: Center(
                child:
                    _StatusIcon(
                  date: sunday.add(
                    Duration(
                      days: i,
                    ),
                  ),
                  scheduledDays:
                      habit
                          .scheduledDays,
                  completedDates:
                      habit
                          .completedDates,
                ),
              ),
            ),

          SizedBox(
            width: 40,
            child: IconButton(
              padding:
                  EdgeInsets.zero,

              icon:
                  const Icon(
                Icons
                    .delete_outline,
                size: 19,
              ),

              onPressed:
                  () async {
                final delete =
                    await showDialog<
                        bool>(
                  context:
                      context,

                  builder:
                      (context) =>
                          AlertDialog(
                    title:
                        const Text(
                      'Delete habit?',
                    ),

                    content:
                        Text(
                      'Remove "${habit.name.isEmpty ? 'Unnamed habit' : habit.name}"?',
                    ),

                    actions: [
                      TextButton(
                        onPressed:
                            () =>
                                Navigator.pop(
                          context,
                          false,
                        ),
                        child:
                            const Text(
                          'Cancel',
                        ),
                      ),

                      TextButton(
                        onPressed:
                            () =>
                                Navigator.pop(
                          context,
                          true,
                        ),
                        child:
                            const Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),
                );

                if (delete ==
                    true) {
                  ref
                      .read(
                        habitControllerProvider
                            .notifier,
                      )
                      .deleteHabit(
                        uid,
                        habit.id,
                      );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon
    extends StatelessWidget {
  const _StatusIcon({
    required this.date,
    required this.scheduledDays,
    required this.completedDates,
  });

  final DateTime date;
  final List<int> scheduledDays;
  final List<String> completedDates;

  @override
  Widget build(
    BuildContext context,
  ) {
    final dateKey =
        '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    // Not scheduled = rest / skipped day.
    if (!scheduledDays.contains(
      date.weekday,
    )) {
      return const Icon(
        Icons.circle_outlined,
        size: 17,
      );
    }

    // Scheduled + completed.
    if (completedDates.contains(
      dateKey,
    )) {
      return const Icon(
        Icons.check,
        size: 18,
      );
    }

    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final currentDate =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    // Scheduled + already passed = missed.
    if (currentDate.isBefore(
      today,
    )) {
      return const Icon(
        Icons.close,
        size: 18,
      );
    }

    // Today/future scheduled day.
    return const CircleAvatar(
      radius: 5,
    );
  }
}