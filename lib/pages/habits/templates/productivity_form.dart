import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProductivityForm extends HookWidget {
  const ProductivityForm({super.key, required this.onChanged});

  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    final feature = useState<String?>(null);

    final sessionController = useTextEditingController();

    final focusController = useTextEditingController();

    final breakController = useTextEditingController();

    final cyclesController = useTextEditingController();

    void update() {
      onChanged({
        'feature': feature.value,
        'sessionLength': feature.value == 'Focus Session'
            ? int.tryParse(sessionController.text.trim())
            : null,
        'focusLength': feature.value == 'Pomodoro'
            ? int.tryParse(focusController.text.trim())
            : null,
        'breakLength': feature.value == 'Pomodoro'
            ? int.tryParse(breakController.text.trim())
            : null,
        'cycles': feature.value == 'Pomodoro'
            ? int.tryParse(cyclesController.text.trim())
            : null,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Productivity', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: feature.value,
          decoration: const InputDecoration(
            labelText: 'Feature',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Focus Session',
              child: Text('Focus Session'),
            ),
            DropdownMenuItem(value: 'Pomodoro', child: Text('Pomodoro')),
          ],
          onChanged: (value) {
            feature.value = value;
            update();
          },
        ),

        const SizedBox(height: 16),

        if (feature.value == 'Focus Session')
          TextField(
            controller: sessionController,
            keyboardType: TextInputType.number,
            onChanged: (_) => update(),
            decoration: const InputDecoration(
              labelText: 'Session length (minutes)',
              border: OutlineInputBorder(),
            ),
          ),

        if (feature.value == 'Pomodoro') ...[
          TextField(
            controller: focusController,
            keyboardType: TextInputType.number,
            onChanged: (_) => update(),
            decoration: const InputDecoration(
              labelText: 'Focus length (minutes)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: breakController,
            keyboardType: TextInputType.number,
            onChanged: (_) => update(),
            decoration: const InputDecoration(
              labelText: 'Break length (minutes)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: cyclesController,
            keyboardType: TextInputType.number,
            onChanged: (_) => update(),
            decoration: const InputDecoration(
              labelText: 'Cycles',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
