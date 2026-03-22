import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/habit.dart';
import '../services/sound_service.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddHabitScreen({super.key, this.habit});

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

  final List<String> _frequencies = [
    'Daily',
    'Weekly',
  ];

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description;
      _selectedCategory = widget.habit!.category;
      _selectedFrequency = widget.habit!.targetFrequency;
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final updatedHabit = widget.habit!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        targetFrequency: _selectedFrequency,
      );
      await DatabaseHelper.instance.updateHabit(updatedHabit);
    } else {
      final habit = Habit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        targetFrequency: _selectedFrequency,
        createdAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertHabit(habit);
    }

    await SoundService.playSave();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Habit Updated!' : 'Habit Saved!'),
      ),
    );

    Navigator.pop(context, true);
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'Add Habit'),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a habit name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
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
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  items: _frequencies
                      .map(
                        (freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        ),
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
                ElevatedButton(
                  onPressed: _saveHabit,
                  child: Text(_isEditing ? 'Update Habit' : 'Save Habit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
