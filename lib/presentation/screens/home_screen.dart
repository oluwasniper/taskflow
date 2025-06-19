// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:taskflow/models/task.dart'; // Make sure this import is correct
import 'dart:math';

// Extension to add UI-specific properties to your existing Priority enum
// This avoids modifying your core model file.
extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.High: // Corrected Casing
        return 'High';
      case Priority.Medium: // Corrected Casing
        return 'Medium';
      case Priority.Low: // Corrected Casing
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case Priority.High: // Corrected Casing
        return Colors.red;
      case Priority.Medium: // Corrected Casing
        return Colors.orange;
      case Priority.Low: // Corrected Casing
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.High: // Corrected Casing
        return Icons.keyboard_double_arrow_up;
      case Priority.Medium: // Corrected Casing
        return Icons.remove;
      case Priority.Low: // Corrected Casing
        return Icons.keyboard_double_arrow_down;
    }
  }
}

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _filteredTasks = _tasks;
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _addTask({
    required String title,
    String description = '',
    Priority priority = Priority.Medium, // Corrected Casing
  }) {
    if (title.isNotEmpty) {
      setState(() {
        final newTask = Task(
          id:
              DateTime.now().toIso8601String() +
              Random().nextInt(1000).toString(),
          title: title,
          description: description,
          priority: priority,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          // reminderDate is removed as it's not in the Task model
        );
        _tasks.add(newTask);
        _updateFilteredTasks();
      });
      _showSnackBar('Task added successfully!', Colors.green);
    }
  }

  void _toggleTask(Task task) {
    setState(() {
      final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = task.copyWith(isCompleted: !task.isCompleted);
      }
      _updateFilteredTasks();
    });

    final message = !task.isCompleted
        ? 'Task completed!'
        : 'Task marked as pending';
    final color = !task.isCompleted ? Colors.green : Colors.orange;
    _showSnackBar(message, color);
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _tasks.removeWhere((t) => t.id == task.id);
                  _updateFilteredTasks();
                });
                Navigator.of(context).pop();
                _showSnackBar('Task deleted', Colors.red);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _updateFilteredTasks() {
    setState(() {
      List<Task> filtered = _tasks;

      if (_searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (task) =>
                  task.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      switch (_currentFilter) {
        case TaskFilter.completed:
          filtered = filtered.where((task) => task.isCompleted).toList();
          break;
        case TaskFilter.pending:
          filtered = filtered.where((task) => !task.isCompleted).toList();
          break;
        case TaskFilter.all:
          break;
      }

      _filteredTasks = filtered;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showCreateTaskPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CreateTaskDialog(
          onCreateTask:
              ({
                required String title,
                String description = '',
                Priority priority = Priority.Medium, // Corrected Casing
              }) {
                _addTask(
                  title: title,
                  description: description,
                  priority: priority,
                );
              },
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff2D2D2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...TaskFilter.values.map((filter) {
                return ListTile(
                  leading: Radio<TaskFilter>(
                    value: filter,
                    groupValue: _currentFilter,
                    activeColor: Colors.blue,
                    onChanged: (TaskFilter? value) {
                      setState(() {
                        _currentFilter = value!;
                        _updateFilteredTasks();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    filter.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _currentFilter = filter;
                      _updateFilteredTasks();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xff1E1E1E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: const _Header(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _SearchBar(
                    onSearchChanged: (query) {
                      _searchQuery = query;
                      _updateFilteredTasks();
                    },
                    onFilterPressed: _showFilterOptions,
                    currentFilter: _currentFilter,
                  ),
                  const SizedBox(height: 20),
                  _TaskStats(tasks: _tasks),
                  const SizedBox(height: 20),
                  const _CustomDivider(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _TaskList(
                tasks: _filteredTasks,
                onToggle: _toggleTask,
                onDelete: _deleteTask,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: _CustomFloatingActionButton(onPressed: _showCreateTaskPopup),
      ),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  final Function({required String title, String description, Priority priority})
  onCreateTask;

  const _CreateTaskDialog({required this.onCreateTask});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Priority _selectedPriority = Priority.Medium; // Corrected Casing

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      widget.onCreateTask(
        title: title,
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_task,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Input
              const Text(
                'Task Title',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter task title...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xff1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),

              // Description Input
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add more details...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xff1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),

              // Priority Selection
              const Text(
                'Priority',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: Priority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.color.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: priority.color)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                priority.icon,
                                color: isSelected
                                    ? priority.color
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priority.displayName,
                                style: TextStyle(
                                  color: isSelected
                                      ? priority.color
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _createTask,
                    child: const Text('Create Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A widget to display the header of the home screen.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Text(
              'Let\'s get things done!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade400],
            ),
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }
}

// A widget for the search bar and filter button.
class _SearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final TaskFilter currentFilter;

  const _SearchBar({
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.blue, size: 20),
            onPressed: onFilterPressed,
            tooltip: 'Filter: ${currentFilter.displayName}',
          ),
        ),
      ],
    );
  }
}

// A widget to display task statistics.
class _TaskStats extends StatelessWidget {
  final List<Task> tasks;

  const _TaskStats({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((task) => task.isCompleted).length;
    final totalCount = tasks.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total',
            value: totalCount.toString(),
            icon: Icons.list_alt,
          ),
          _StatItem(
            label: 'Completed',
            value: completedCount.toString(),
            icon: Icons.check_circle,
          ),
          _StatItem(
            label: 'Progress',
            value: '${(completionRate * 100).toInt()}%',
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}

// A widget for a single statistic item.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// A custom divider widget with a gradient.
class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// A widget to display the list of tasks.
class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onToggle;
  final Function(Task) onDelete;

  const _TaskList({
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No tasks found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started!',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? const Color(0xff2D2D2D).withOpacity(0.7)
                : const Color(0xff2D2D2D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey[800]!,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: GestureDetector(
              onTap: () => onToggle(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : Colors.blue,
                  size: 24,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey[500] : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: task.priority.color),
                  ),
                  child: Text(
                    task.priority.displayName,
                    style: TextStyle(
                      color: task.priority.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  onPressed: () => onDelete(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// A custom Floating Action Button.
class _CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CustomFloatingActionButton({required this.onPressed});

  @override
  State<_CustomFloatingActionButton> createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState
    extends State<_CustomFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: widget.onPressed,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
