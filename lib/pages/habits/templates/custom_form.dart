import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  const CustomForm({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),

        const SizedBox(height: 12),

        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Target',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}