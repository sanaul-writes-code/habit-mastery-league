import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/habit.dart';
import '../services/sound_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General';
  String _selectedFrequency = 'Daily';

  final List<String> _categories = [
    'General',
    'Health',
    'Fitness',
    'Productivity',
    'Mindfulness',
  ];

  final List<String> _frequencies = ['Daily', 'Weekly'];

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      targetFrequency: _selectedFrequency,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.insertHabit(habit);
    await SoundService.playSave();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habit Saved!')));
    }

    _nameController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F4FF), Color(0xFFEDE7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                /// Habit Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter a habit name'
                      : null,
                ),

                const SizedBox(height: 16),

                /// Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// Frequency
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  items: _frequencies
                      .map(
                        (freq) =>
                            DropdownMenuItem(value: freq, child: Text(freq)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFrequency = value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                /// Save Button
                ElevatedButton(
                  onPressed: _saveHabit,
                  child: const Text('Save Habit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
