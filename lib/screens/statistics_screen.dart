// statistics_screen.dart
// Statistics screen UI

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  int _totalHabits = 0;
  int _completedToday = 0;
  int _totalCompletions = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final totalHabits = await DatabaseHelper.instance.getTotalHabitsCount();
    final completedToday = await DatabaseHelper.instance.getCompletedTodayCount();
    final totalCompletions = await DatabaseHelper.instance.getTotalCompletionCount();
    final longestStreak = await DatabaseHelper.instance.getLongestStreakAcrossHabits();

    if (!mounted) return;

    setState(() {
      _totalHabits = totalHabits;
      _completedToday = completedToday;
      _totalCompletions = totalCompletions;
      _longestStreak = longestStreak;
      _isLoading = false;
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF6C63FF);
    const pinkAccent = Color(0xFFFF7AA2);
    const tealAccent = Color(0xFF26C6DA);
    const amberAccent = Color(0xFFFFB74D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F4FF),
              Color(0xFFEDE7FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Your Progress Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quick look at your habit performance.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildStatCard(
                    title: 'Total Habits',
                    value: '$_totalHabits',
                    icon: Icons.track_changes,
                    color: deepPurple,
                  ),
                  _buildStatCard(
                    title: 'Completed Today',
                    value: '$_completedToday',
                    icon: Icons.check_circle,
                    color: tealAccent,
                  ),
                  _buildStatCard(
                    title: 'Total Completions',
                    value: '$_totalCompletions',
                    icon: Icons.bar_chart,
                    color: pinkAccent,
                  ),
                  _buildStatCard(
                    title: 'Longest Streak',
                    value: '$_longestStreak day(s)',
                    icon: Icons.local_fire_department,
                    color: amberAccent,
                  ),
                ],
              ),
      ),
    );
  }
}
