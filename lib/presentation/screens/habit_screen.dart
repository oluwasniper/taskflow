// lib/presentation/screens/habits_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xff1E1E1E,
      ), // Dark background for consistency
      appBar: AppBar(
        title: const Text('My Habits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // TODO: Implement habit creation logic or navigate to AddHabitScreen
              _showAddHabitDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHabitsHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle('Daily Habits'),
          const SizedBox(height: 10),
          _buildDailyHabitsList(),
          const SizedBox(height: 30),
          _buildSectionTitle('Weekly Habits'),
          const SizedBox(height: 10),
          _buildWeeklyHabitsList(),
          const SizedBox(height: 30),
          _buildSectionTitle('Goals & Long-term Habits'),
          const SizedBox(height: 10),
          _buildLongTermHabitsList(),
        ],
      ),
    );
  }

  Widget _buildHabitsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cultivate Good Habits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your progress and build consistent routines.',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // --- Habit List Builders (for different categories) ---

  Widget _buildDailyHabitsList() {
    return Column(
      children: [
        _buildHabitCard(
          habitName: 'Drink 8 Glasses of Water',
          progress: '5/8 Glasses',
          completionPercentage: 0.625,
          icon: Icons.local_drink_outlined,
          iconColor: Colors.blue,
          onTap: () {
            // TODO: Implement habit tracking/details for Water
          },
        ),
        const SizedBox(height: 15),
        _buildHabitCard(
          habitName: 'Read for 30 Minutes',
          progress: '20/30 Mins',
          completionPercentage: 0.66,
          icon: Icons.menu_book,
          iconColor: Colors.deepPurple,
          onTap: () {
            // TODO: Implement habit tracking/details for Reading
          },
        ),
        const SizedBox(height: 15),
        _buildHabitCard(
          habitName: 'Daily Meditation',
          progress: 'Completed',
          completionPercentage: 1.0,
          icon: Icons.self_improvement,
          iconColor: Colors.green,
          onTap: () {
            // TODO: Implement habit tracking/details for Meditation
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyHabitsList() {
    return Column(
      children: [
        _buildHabitCard(
          habitName: 'Exercise 3 Times',
          progress: '1/3 Sessions',
          completionPercentage: 0.33,
          icon: Icons.fitness_center,
          iconColor: Colors.redAccent,
          onTap: () {
            // TODO: Implement habit tracking/details for Exercise
          },
        ),
        const SizedBox(height: 15),
        _buildHabitCard(
          habitName: 'Plan Week Ahead',
          progress: 'Not Started',
          completionPercentage: 0.0,
          icon: Icons.calendar_today,
          iconColor: Colors.orange,
          onTap: () {
            // TODO: Implement habit tracking/details for Planning
          },
        ),
      ],
    );
  }

  Widget _buildLongTermHabitsList() {
    return Column(
      children: [
        _buildHabitCard(
          habitName: 'Learn New Language',
          progress: 'Chapter 5/20',
          completionPercentage: 0.25,
          icon: Icons.language,
          iconColor: Colors.teal,
          onTap: () {
            // TODO: Implement habit tracking/details for Language
          },
        ),
      ],
    );
  }

  // --- Reusable Habit Card Widget ---

  Widget _buildHabitCard({
    required String habitName,
    required String progress,
    required double completionPercentage,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xff2D2D2D), // Card background color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: completionPercentage,
                      backgroundColor: Colors.grey[700],
                      color: iconColor, // Use habit's color for progress
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialog for Adding New Habit (Example) ---
  void _showAddHabitDialog(BuildContext context) {
    TextEditingController _habitNameController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff2D2D2D), // Dark dialog background
          title: const Text(
            'Add New Habit',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _habitNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // TODO: Add more fields like frequency, start date, etc.
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement logic to save the new habit
                print('New Habit: ${_habitNameController.text}');
                print('Description: ${_descriptionController.text}');
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Consistent accent color
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Habit'),
            ),
          ],
        );
      },
    );
  }
}
