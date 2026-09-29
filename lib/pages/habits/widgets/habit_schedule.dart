import 'package:flutter/material.dart';

class HabitSchedule extends StatefulWidget {
  const HabitSchedule({
    super.key,
    required this.onChanged,
  });

  final void Function(
    List<int> days,
    TimeOfDay? time,
  ) onChanged;

  @override
  State<HabitSchedule> createState() => _HabitScheduleState();
}

class _HabitScheduleState extends State<HabitSchedule> {
  final List<int> _selectedDays = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ];

  TimeOfDay? _time;

  static const days = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  void _update() {
    widget.onChanged(
      List<int>.from(_selectedDays),
      _time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which days?',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 7; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedDays.contains(i + 1)) {
                      _selectedDays.remove(i + 1);
                    } else {
                      _selectedDays.add(i + 1);
                      _selectedDays.sort();
                    }
                  });

                  _update();
                },
                child: Column(
                  children: [
                    Text(days[i]),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedDays.contains(i + 1)
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                            : Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          '${_selectedDays.length} day(s) per week',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _time ?? TimeOfDay.now(),
            );

            if (time != null) {
              setState(() {
                _time = time;
              });

              _update();
            }
          },
          icon: const Icon(Icons.access_time),
          label: Text(
            _time == null
                ? 'Select time'
                : 'Time: ${_time!.format(context)}',
          ),
        ),
      ],
    );
  }
}  