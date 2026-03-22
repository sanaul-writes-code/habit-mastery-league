// dashboard_screen.dart
// Dashboard screen UI

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/habit.dart';
import '../services/sound_service.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';
import 'statistics_screen.dart';

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
    await SoundService.playOpen();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );

    await _loadHabits();
  }

  Future<void> _markHabitComplete(Habit habit) async {
    await DatabaseHelper.instance.markHabitCompletedToday(habit.id!);
    await SoundService.playComplete();
    await _loadHabits();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${habit.name} marked complete!')));
  }

  IconData _getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'fitness':
        return Icons.fitness_center;
      case 'productivity':
        return Icons.work;
      case 'mindfulness':
        return Icons.self_improvement;
      default:
        return Icons.track_changes;
    }
  }

  Color _getHabitColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return const Color(0xFFFF6B81);
      case 'fitness':
        return const Color(0xFF4ECDC4);
      case 'productivity':
        return const Color(0xFF6C63FF);
      case 'mindfulness':
        return const Color(0xFFFFB74D);
      default:
        return const Color(0xFF7986CB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Mastery League',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () async {
              await SoundService.playOpen();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
              await _loadHabits();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F4FF), Color(0xFFEDE7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8E7CFF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay Consistent',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Build momentum one habit at a time.',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _habits.isEmpty
                        ? const Center(
                            child: Text(
                              'No habits yet.\nTap + to add your first habit.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _habits.length,
                            itemBuilder: (context, index) {
                              final habit = _habits[index];
                              final accentColor = _getHabitColor(
                                habit.category,
                              );

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: accentColor.withOpacity(
                                      0.12,
                                    ),
                                    child: Icon(
                                      _getHabitIcon(habit.category),
                                      color: accentColor,
                                    ),
                                  ),
                                  title: Text(
                                    habit.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${habit.category} • ${habit.targetFrequency}',
                                  ),
                                  trailing: SizedBox(
                                    width: 72,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                          ),
                                          color: accentColor,
                                          onPressed: () =>
                                              _markHabitComplete(habit),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    await SoundService.playTap();
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            HabitDetailsScreen(habit: habit),
                                      ),
                                    );

                                    await _loadHabits();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        onPressed: _openAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
