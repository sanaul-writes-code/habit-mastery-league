import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/sound_service.dart';
import 'add_habit_screen.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  bool _completedToday = false;
  bool _isLoading = true;
  List<HabitLog> _logs = [];
  int _streak = 0;
  int _totalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadHabitDetails();
  }

  Future<void> _loadHabitDetails() async {
    final completedToday = await DatabaseHelper.instance.isHabitCompletedToday(
      widget.habit.id!,
    );
    final logs = await DatabaseHelper.instance.getLogsForHabit(
      widget.habit.id!,
    );
    final streak = await DatabaseHelper.instance.getHabitStreak(
      widget.habit.id!,
    );
    final totalCompleted = await DatabaseHelper.instance.getTotalCompletedCount(
      widget.habit.id!,
    );

    if (!mounted) return;

    setState(() {
      _completedToday = completedToday;
      _logs = logs;
      _streak = streak;
      _totalCompleted = totalCompleted;
      _isLoading = false;
    });
  }

  Future<void> _markCompletedToday() async {
    await DatabaseHelper.instance.markHabitCompletedToday(widget.habit.id!);
    SoundService.playComplete();
    await _loadHabitDetails();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit marked complete for today!')),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editHabit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteHabit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Category: ${habit.category}'),
                  const SizedBox(height: 8),
                  Text('Frequency: ${habit.targetFrequency}'),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${habit.description.isEmpty ? "No description" : habit.description}',
                  ),
                  const SizedBox(height: 16),
                  Text('Current Streak: $_streak day(s)'),
                  const SizedBox(height: 8),
                  Text('Total Completions: $_totalCompleted'),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completedToday ? null : _markCompletedToday,
                      child: Text(
                        _completedToday
                            ? 'Already Completed Today'
                            : 'Mark Completed Today',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Completion History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text('No completion history yet.'),
                          )
                        : ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(_formatDate(log.completedDate)),
                                  subtitle: Text(
                                    log.status ? 'Completed' : 'Incomplete',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _editHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddHabitScreen(habit: widget.habit),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteHabit() async {
    SoundService.playDelete();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: const Text('Are you sure you want to delete this habit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await DatabaseHelper.instance.deleteHabit(widget.habit.id!);

    if (!mounted) return;

    Navigator.pop(context, true);
  }
}
