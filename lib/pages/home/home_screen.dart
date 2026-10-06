import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/auth.dart';
import 'package:again/features/habits.dart';
import 'package:again/features/notifications.dart';
import 'package:again/pages/contacts/contacts_screen.dart';
import 'package:again/pages/habits/habits_screen.dart';
import 'package:again/pages/habits/select_habit_type_screen.dart';
import 'package:again/pages/notifications/notifications_screen.dart';
import 'package:again/pages/profile/profile_screen.dart';
import 'package:again/pages/stats/stats_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState(0);

    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const SizedBox();
    }

    final notifications = ref.watch(notificationsProvider(user.uid));

    final unreadCount = notifications.maybeWhen(
      data: (items) => items.where((item) => item['read'] != true).length,
      orElse: () => 0,
    );

    final pages = [
      _TodayView(uid: user.uid),
      HabitsScreen(uid: user.uid),
      ContactsScreen(uid: user.uid),
      StatsScreen(uid: user.uid),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user.displayName ?? 'there'}'),
        actions: [
          // -------------------------------------------------
          // NOTIFICATIONS
          // -------------------------------------------------

          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(uid: user.uid),
                    ),
                  );
                },
              ),

              if (unreadCount > 0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // -------------------------------------------------
          // PROFILE
          // -------------------------------------------------
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: user.uid),
                ),
              );
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: pages[index.value],

      floatingActionButton: index.value == 0 || index.value == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectHabitTypeScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: index.value,
        onDestinationSelected: (value) {
          index.value = value;
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

class _TodayView extends ConsumerWidget {
  const _TodayView({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider(uid));

    return habits.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (habits) {
        final today = _today();

        final completed = habits
            .where((habit) => habit.completedDates.contains(today))
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Today', style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 4),

            Text(_date()),

            const SizedBox(height: 20),

            Text('$completed of ${habits.length} completed'),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: habits.isEmpty ? 0 : completed / habits.length,
            ),

            const SizedBox(height: 20),

            if (habits.isEmpty)
              const Center(child: Text('No habits yet.'))
            else
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final habit in habits)
                      _TodayHabit(habit: habit, uid: uid, today: today),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _today() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _date() {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${now.day} '
        '${months[now.month - 1]} '
        '${now.year}';
  }
}

class _TodayHabit extends ConsumerWidget {
  const _TodayHabit({
    required this.habit,
    required this.uid,
    required this.today,
  });

  final Habit habit;
  final String uid;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = habit.completedDates.contains(today);

    return SizedBox(
      height: 54,
      child: Row(
        children: [
          Checkbox(
            value: completed,
            shape: const CircleBorder(),
            onChanged: (value) {
              ref
                  .read(habitControllerProvider.notifier)
                  .toggleHabit(uid, habit.id, today, value ?? false);
            },
          ),

          Expanded(
            child: Text(
              habit.name.isEmpty ? 'Unnamed habit' : habit.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (habit.reminderTime != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                habit.reminderTime!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
