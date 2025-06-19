// lib/presentation/screens/task_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart'; // Import for groupBy

// --- Data Models ---
enum ItemStatus { pending, completed, urgent }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final ItemStatus status;
  final List<String> tags; // Could be categories too

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = ItemStatus.pending,
    this.tags = const [],
  });

  // Example factory for mock data
  factory Task.mock({
    required String title,
    required String description,
    required DateTime dueDate,
    ItemStatus status = ItemStatus.pending,
    List<String> tags = const [],
  }) {
    return Task(
      id: UniqueKey().toString(), // Simple unique ID for mock
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      tags: tags,
    );
  }

  Task copyWith({ItemStatus? status}) {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      status: status ?? this.status,
      tags: tags,
    );
  }
}

// --- TaskScreen ---
enum TaskFilter { all, urgent, completed, overdue }

@RoutePage()
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TaskFilter _currentFilter = TaskFilter.all;

  // Mock Data - Using Task instead of ListItem
  List<Task> _allTasks = [
    Task.mock(
      title: 'Design UI for Onboarding',
      description:
          'Create wireframes and mockups for the new user onboarding flow.',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      tags: ['Design', 'UI/UX'],
    ),
    Task.mock(
      title: 'Fix Bug in Auth Flow',
      description:
          'Users are reporting issues with social login. Investigate and fix.',
      dueDate: DateTime.now().subtract(
        const Duration(days: 1),
      ), // Overdue relative to current time
      status: ItemStatus.urgent,
      tags: ['Development', 'Urgent'],
    ),
    Task.mock(
      title: 'Prepare Q3 Report',
      description:
          'Compile sales data and market analysis for the quarterly review.',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      tags: ['Reporting', 'Analytics'],
    ),
    Task.mock(
      title: 'Review PR #123',
      description: 'Code review for the new feature branch.',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      tags: ['Development', 'Code'],
      status: ItemStatus.urgent,
    ),
    Task.mock(
      title: 'Schedule Team Sync',
      description:
          'Find a suitable time for the weekly team synchronization meeting.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: ItemStatus.completed, // Already completed
      tags: ['Meeting', 'Admin'],
    ),
    Task.mock(
      title: 'Research State Management',
      description:
          'Explore options like BLoC, Riverpod, and Provider for the new project.',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      tags: ['Research', 'Development'],
    ),
  ];

  List<Task> get _filteredTasks {
    final now = DateTime.now();
    return _allTasks.where((task) {
      switch (_currentFilter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.urgent:
          return task.status == ItemStatus.urgent;
        case TaskFilter.completed:
          return task.status == ItemStatus.completed;
        case TaskFilter.overdue:
          // Check if due date is before today (start of day) and not completed
          return task.dueDate.isBefore(
                DateTime(now.year, now.month, now.day),
              ) &&
              task.status != ItemStatus.completed;
      }
    }).toList();
  }

  // --- Helper to update task status ---
  void _toggleTaskStatus(Task task) {
    setState(() {
      final int index = _allTasks.indexOf(task);
      if (index != -1) {
        _allTasks[index] = task.copyWith(
          status: task.status == ItemStatus.completed
              ? ItemStatus.pending
              : ItemStatus.completed,
        );
      }
    });
  }

  // --- Helper to get due date string ---
  String _getDueDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final itemDate = DateTime(
      date.year,
      date.month,
      date.day,
    ); // Date part only for comparison

    if (itemDate.isAtSameMomentAs(today)) {
      return 'Due Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (itemDate.isAtSameMomentAs(tomorrow)) {
      return 'Due Tomorrow at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (itemDate.isBefore(today)) {
      return 'Overdue! ${date.month}/${date.day}/${date.year}';
    }
    return 'Due on ${date.month}/${date.day}/${date.year}';
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      appBar: AppBar(
        title: const Text('My Tasks'), // Renamed title
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: _buildFilterChips(),
        ),
      ),
      body: _filteredTasks.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildListHeader(),
                const SizedBox(height: 20),
                _buildCategorizedList(),
              ],
            ),
    );
  }

  // --- Widgets for screen sections ---

  Widget _buildListHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Current Focus',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Viewing ${_currentFilter.name.capitalize()} tasks.', // Updated text
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          children: TaskFilter.values.map((filter) {
            return ChoiceChip(
              label: Text(filter.name.capitalize()),
              selected: _currentFilter == filter,
              selectedColor: Colors.blue.withOpacity(0.3),
              backgroundColor: const Color(0xff2D2D2D),
              labelStyle: TextStyle(
                color: _currentFilter == filter
                    ? Colors.blue
                    : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: _currentFilter == filter
                    ? Colors.blue
                    : Colors.grey[700]!,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilter = filter;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorizedList() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Start of today
    final tomorrow = today.add(const Duration(days: 1)); // Start of tomorrow

    // Use groupBy from package:collection
    final Map<String, List<Task>> groupedTasks = groupBy<Task, String>(
      _filteredTasks,
      (task) {
        if (task.dueDate.isBefore(today) &&
            task.status != ItemStatus.completed) {
          return 'Overdue';
        } else if (task.dueDate.isAtSameMomentAs(today) ||
            (task.dueDate.isAfter(today) && task.dueDate.isBefore(tomorrow))) {
          // Tasks due today or before end of today
          return 'Today / Tomorrow';
        } else {
          return 'Upcoming';
        }
      },
    );

    // Ensure a specific order for the groups, and only include existing groups
    final List<String> orderedKeys = [
      'Overdue',
      'Today / Tomorrow',
      'Upcoming',
    ].where((key) => groupedTasks.containsKey(key)).toList();

    return Column(
      children: orderedKeys.map((key) {
        return _buildCategorySection(
          categoryTitle: key,
          tasks: groupedTasks[key]!,
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection({
    required String categoryTitle,
    required List<Task> tasks, // Renamed from items to tasks
  }) {
    if (tasks.isEmpty)
      return const SizedBox.shrink(); // Don't show empty sections

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            categoryTitle,
            style: TextStyle(
              color: categoryTitle == 'Overdue'
                  ? Colors.redAccent
                  : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Map tasks to _buildTaskCard
        ...tasks.map((task) => _buildTaskCard(task)).toList(),
        const SizedBox(height: 20), // Spacing between categories
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    // Renamed from _buildListItemCard to _buildTaskCard
    return Card(
      color: const Color(0xff2D2D2D),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to task details screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${task.title}'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusIndicator(task.status), // Dynamic status icon
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.status == ItemStatus.completed
                            ? Colors.grey[500]
                            : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == ItemStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildTagsRow(task.tags), // Dynamic tags
                    const SizedBox(height: 8),
                    Text(
                      _getDueDateString(task.dueDate),
                      style: TextStyle(
                        color: task.status == ItemStatus.completed
                            ? Colors.grey[500]
                            : task.dueDate.isBefore(DateTime.now()) &&
                                  task.status != ItemStatus.completed
                            ? Colors.red
                            : Colors.grey[400],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Checkbox or action button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    task.status == ItemStatus.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.status == ItemStatus.completed
                        ? Colors.green
                        : Colors.grey[500],
                  ),
                  onPressed: () => _toggleTaskStatus(task),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ItemStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case ItemStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        break;
      case ItemStatus.completed:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case ItemStatus.urgent:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
    }
    return Icon(icon, color: color, size: 28);
  }

  Widget _buildTagsRow(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: tags.map((tag) => _buildTagChip(tag)).toList(),
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(
        tag,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: Colors.blueGrey.withOpacity(0.5),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_currentFilter) {
      case TaskFilter.all:
        message = 'No tasks yet! Add some to get started.';
        break;
      case TaskFilter.urgent:
        message = 'No urgent tasks right now. Great job!';
        break;
      case TaskFilter.completed:
        message = 'You haven\'t completed any tasks with this filter.';
        break;
      case TaskFilter.overdue:
        message = 'No overdue tasks! Keep up the good work.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add task screen or show dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Imagine adding a new task here!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add New Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Extension for string capitalization (utility) ---
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
