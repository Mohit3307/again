import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FitnessForm extends HookWidget {
  const FitnessForm({super.key, required this.onChanged});

  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    final activity = useState('Gym');
    final runningType = useState('Running');

    final exercises = useState<List<Map<String, dynamic>>>([]);

    final asanas = useState<List<Map<String, dynamic>>>([]);

    final distanceController = useTextEditingController();

    final durationController = useTextEditingController();

    final runningTargetController = useTextEditingController();

    final yogaTargetController = useTextEditingController();

    void update() {
      if (activity.value == 'Gym') {
        onChanged({'activity': 'Gym', 'exercises': exercises.value});
      }

      if (activity.value == 'Running / Walking') {
        onChanged({
          'activity': 'Running / Walking',
          'type': runningType.value,
          'distance': double.tryParse(distanceController.text.trim()),
          'duration': int.tryParse(durationController.text.trim()),
          'target': runningTargetController.text.trim(),
        });
      }

      if (activity.value == 'Yoga') {
        onChanged({
          'activity': 'Yoga',
          'asanas': asanas.value,
          'target': yogaTargetController.text.trim(),
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: activity.value,
          decoration: const InputDecoration(
            labelText: 'Activity',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Gym', child: Text('Gym')),
            DropdownMenuItem(
              value: 'Running / Walking',
              child: Text('Running / Walking'),
            ),
            DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
          ],
          onChanged: (value) {
            if (value != null) {
              activity.value = value;
              update();
            }
          },
        ),

        const SizedBox(height: 20),

        if (activity.value == 'Gym')
          _GymForm(
            exercises: exercises.value,
            onChanged: (value) {
              exercises.value = value;
              update();
            },
          ),

        if (activity.value == 'Running / Walking')
          _RunningForm(
            activity: runningType,
            distanceController: distanceController,
            durationController: durationController,
            targetController: runningTargetController,
            onChanged: update,
          ),

        if (activity.value == 'Yoga')
          _YogaForm(
            asanas: asanas.value,
            targetController: yogaTargetController,
            onChanged: (value) {
              asanas.value = value;
              update();
            },
          ),
      ],
    );
  }
}

// ------------------------------------------------------------
// GYM
// ------------------------------------------------------------

class _GymForm extends StatelessWidget {
  const _GymForm({required this.exercises, required this.onChanged});

  final List<Map<String, dynamic>> exercises;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercises', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 8),

        for (var i = 0; i < exercises.length; i++)
          Card(
            child: ListTile(
              title: Text(exercises[i]['name']),
              subtitle: Text(
                '${exercises[i]['sets']} sets × '
                '${exercises[i]['reps']} reps • '
                '${exercises[i]['weight']} kg',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final list = [...exercises]..removeAt(i);

                  onChanged(list);
                },
              ),
            ),
          ),

        OutlinedButton.icon(
          onPressed: () async {
            final exercise = await _showExerciseDialog(context);

            if (exercise != null) {
              onChanged([...exercises, exercise]);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Exercise'),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showExerciseDialog(
    BuildContext context,
  ) async {
    final name = TextEditingController();
    final sets = TextEditingController();
    final reps = TextEditingController();
    final weight = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Exercise name'),
              ),
              TextField(
                controller: sets,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
              TextField(
                controller: reps,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, {
                  'name': name.text.trim(),
                  'sets': int.tryParse(sets.text) ?? 0,
                  'reps': int.tryParse(reps.text) ?? 0,
                  'weight': double.tryParse(weight.text) ?? 0,
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// ------------------------------------------------------------
// RUNNING / WALKING
// ------------------------------------------------------------

class _RunningForm extends StatelessWidget {
  const _RunningForm({
    required this.activity,
    required this.distanceController,
    required this.durationController,
    required this.targetController,
    required this.onChanged,
  });

  final ValueNotifier<String> activity;
  final TextEditingController distanceController;
  final TextEditingController durationController;
  final TextEditingController targetController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: activity.value,
          decoration: const InputDecoration(
            labelText: 'Activity',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Running', child: Text('Running')),
            DropdownMenuItem(value: 'Walking', child: Text('Walking')),
          ],
          onChanged: (value) {
            if (value != null) {
              activity.value = value;
              onChanged();
            }
          },
        ),

        const SizedBox(height: 16),

        TextField(
          controller: distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Distance (km)',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Duration (minutes)',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: targetController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Target',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// YOGA
// ------------------------------------------------------------

class _YogaForm extends StatelessWidget {
  const _YogaForm({
    required this.asanas,
    required this.targetController,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> asanas;
  final TextEditingController targetController;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asanas / Poses', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 8),

        for (var i = 0; i < asanas.length; i++)
          Card(
            child: ListTile(
              title: Text(asanas[i]['name']),
              subtitle: Text('${asanas[i]['duration']} minutes'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final list = [...asanas]..removeAt(i);

                  onChanged(list);
                },
              ),
            ),
          ),

        OutlinedButton.icon(
          onPressed: () async {
            final asana = await _showAsanaDialog(context);

            if (asana != null) {
              onChanged([...asanas, asana]);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Asana'),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: targetController,
          onChanged: (_) {
            onChanged([...asanas]);
          },
          decoration: const InputDecoration(
            labelText: 'Overall target',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showAsanaDialog(BuildContext context) async {
    final name = TextEditingController();
    final duration = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Asana'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Asana / Pose name',
                ),
              ),
              TextField(
                controller: duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, {
                  'name': name.text.trim(),
                  'duration': int.tryParse(duration.text) ?? 0,
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
