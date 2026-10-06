import 'dart:async';

import 'package:flutter/material.dart';

import 'package:again/core/models/habit.dart';

class HabitTimerScreen extends StatefulWidget {
  const HabitTimerScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitTimerScreen> createState() => _HabitTimerScreenState();
}

class _HabitTimerScreenState extends State<HabitTimerScreen> {
  Timer? _timer;

  late int remainingSeconds;

  bool running = false;

  int currentCycle = 1;
  bool isBreak = false;

  @override
  void initState() {
    super.initState();

    remainingSeconds = _initialSeconds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _initialSeconds() {
    if (widget.habit.feature == 'Pomodoro') {
      return (widget.habit.focusLength ?? 25) * 60;
    }

    return (widget.habit.sessionLength ?? 25) * 60;
  }

  void _start() {
    if (running) return;

    setState(() {
      running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds <= 1) {
        _handleFinishedPhase();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  void _pause() {
    _timer?.cancel();

    setState(() {
      running = false;
    });
  }

  void _reset() {
    _timer?.cancel();

    setState(() {
      running = false;
      currentCycle = 1;
      isBreak = false;
      remainingSeconds = _initialSeconds();
    });
  }

  void _handleFinishedPhase() {
    _timer?.cancel();

    if (widget.habit.feature != 'Pomodoro') {
      setState(() {
        running = false;
        remainingSeconds = 0;
      });
      return;
    }

    final cycles = widget.habit.cycles ?? 1;

    if (!isBreak) {
      if (currentCycle >= cycles) {
        setState(() {
          running = false;
          remainingSeconds = 0;
        });
        return;
      }

      setState(() {
        isBreak = true;
        remainingSeconds = (widget.habit.breakLength ?? 5) * 60;
        running = false;
      });

      return;
    }

    setState(() {
      isBreak = false;
      currentCycle++;
      remainingSeconds = (widget.habit.focusLength ?? 25) * 60;
      running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;

    final seconds = remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: Text(widget.habit.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.habit.feature == 'Pomodoro')
                Text(
                  isBreak
                      ? 'Break'
                      : 'Focus • Cycle $currentCycle/${widget.habit.cycles ?? 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                )
              else
                Text(
                  'Focus Session',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

              const SizedBox(height: 32),

              Text(
                '${minutes.toString().padLeft(2, '0')}:'
                '${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!running)
                    ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _pause,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),

                  const SizedBox(width: 12),

                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Keep this screen open while the timer runs.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
