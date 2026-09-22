import 'package:flutter/material.dart';

import 'package:again/pages/habits/create_habit_screen.dart';

class SelectHabitTypeScreen extends StatelessWidget {
  const SelectHabitTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const types = ['Productivity', 'Fitness', 'Health', 'Custom'];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Habit Type')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final type in types)
            Card(
              child: ListTile(
                title: Text(type),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateHabitScreen(type: type),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
