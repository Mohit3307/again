import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HealthForm extends HookWidget {
  const HealthForm({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = useState('30 days');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          initialValue: duration.value,
          decoration: const InputDecoration(
            labelText: 'Duration',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: '7 days',
              child: Text('7 days'),
            ),
            DropdownMenuItem(
              value: '14 days',
              child: Text('14 days'),
            ),
            DropdownMenuItem(
              value: '30 days',
              child: Text('30 days'),
            ),
            DropdownMenuItem(
              value: '60 days',
              child: Text('60 days'),
            ),
            DropdownMenuItem(
              value: '90 days',
              child: Text('90 days'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              duration.value = value;
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}