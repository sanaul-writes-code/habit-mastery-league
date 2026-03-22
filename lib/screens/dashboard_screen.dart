// dashboard_screen.dart
// Dashboard screen UI

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/habit.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    final habits = await DatabaseHelper.instance.getHabits();

    if (!mounted) return;

    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _openAddHabitScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );

    await _loadHabits();
  }

  Future<void> _markHabitComplete(Habit habit) async {
    await DatabaseHelper.instance.markHabitCompletedToday(habit.id!);
    await _loadHabits();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('[4m{habit.name} marked complete!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Mastery League')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet.\nTap + to add your first habit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(habit.name),
                    subtitle: Text(
                      '${habit.category} • ${habit.targetFrequency}',
                    ),
                    trailing: SizedBox(
                      width: 72,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () => _markHabitComplete(habit),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HabitDetailsScreen(habit: habit),
                        ),
                      );
                      await _loadHabits();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
