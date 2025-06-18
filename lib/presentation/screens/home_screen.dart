import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:taskflow/models/task.dart';
import 'dart:math';

// lib/models/task.dart

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // A list to hold all the Task objects.
  final List<Task> _tasks = [];
  // A list to hold the tasks that are currently visible after filtering.
  List<Task> _filteredTasks = [];
  // The current search query entered by the user.
  String _searchQuery = '';
  // The currently selected task filter.
  TaskFilter _currentFilter = TaskFilter.all;
  // A boolean to control the visibility of the new task input card.
  bool _isNewTaskCardVisible = false;

  // Animation controller for the Floating Action Button.
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

  // Toggles the visibility of the new task card.
  void _toggleNewTaskCard() {
    setState(() {
      _isNewTaskCardVisible = !_isNewTaskCardVisible;
    });
  }

  // Adds a new task to the list.
  void _addTask(String title) {
    if (title.isNotEmpty) {
      setState(() {
        final newTask = Task(
          id:
              DateTime.now().toIso8601String() +
              Random().nextInt(1000).toString(),
          title: title,
          dueDate: DateTime.now(),
        );
        _tasks.add(newTask);
        _updateFilteredTasks();
        _isNewTaskCardVisible = false;
      });
      _showSnackBar('Task added successfully!', Colors.green);
    }
  }

  // Toggles the completion status of a task.
  void _toggleTask(Task task) {
    setState(() {
      final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = task.copyWith(isCompleted: !task.isCompleted);
      }
      _updateFilteredTasks();
    });
  }

  // Deletes a task from the list.
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
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(color: Colors.grey),
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

  // Updates the list of filtered tasks based on the search query and current filter.
  void _updateFilteredTasks() {
    setState(() {
      List<Task> filtered = _tasks;

      // Apply search filter.
      if (_searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (task) =>
                  task.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      // Apply status filter.
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

  // Shows a SnackBar with a message and color.
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

  // Shows a modal bottom sheet with filter options.
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // The main app bar with a header.
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
              // The main content of the screen, including search, stats, and tasks.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // The search bar and filter button.
                      _SearchBar(
                        onSearchChanged: (query) {
                          _searchQuery = query;
                          _updateFilteredTasks();
                        },
                        onFilterPressed: () => _showFilterOptions(),
                      ),
                      const SizedBox(height: 20),
                      // The task statistics section.
                      _TaskStats(tasks: _tasks),
                      const SizedBox(height: 20),
                      const _CustomDivider(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // The list of tasks.
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
          // The floating card for adding a new task.
          _NewTaskCard(
            isVisible: _isNewTaskCardVisible,
            onAddTask: _addTask,
            onCancel: _toggleNewTaskCard,
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: _CustomFloatingActionButton(onPressed: _toggleNewTaskCard),
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
              colors: [Colors.blue, Colors.blue.shade300],
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

  const _SearchBar({
    required this.onSearchChanged,
    required this.onFilterPressed,
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
            title: Text(
              task.title,
              style: TextStyle(
                color: task.isCompleted ? Colors.grey[500] : Colors.white,
                fontSize: 16,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20,
              ),
              onPressed: () => onDelete(task),
            ),
          ),
        );
      },
    );
  }
}

// A widget for the floating card to add a new task.
class _NewTaskCard extends StatefulWidget {
  final bool isVisible;
  final Function(String) onAddTask;
  final VoidCallback onCancel;

  const _NewTaskCard({
    required this.isVisible,
    required this.onAddTask,
    required this.onCancel,
  });

  @override
  State<_NewTaskCard> createState() => _NewTaskCardState();
}

class _NewTaskCardState extends State<_NewTaskCard> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: GestureDetector(
        onTap: widget.onCancel,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap:
                    () {}, // Prevents the card from closing when tapped inside.
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xff2D2D2D).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add New Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _taskController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'What do you need to do?',
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _taskController.clear();
                              widget.onCancel();
                            },
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              widget.onAddTask(_taskController.text.trim());
                              _taskController.clear();
                            },
                            child: const Text('Add Task'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A custom Floating Action Button with a pressed animation.
class _CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CustomFloatingActionButton({required this.onPressed});

  @override
  State<_CustomFloatingActionButton> createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState
    extends State<_CustomFloatingActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.blue.shade600],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: _isPressed ? 5 : 10,
              offset: Offset(0, _isPressed ? 2 : 4),
              spreadRadius: _isPressed ? 1 : 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          splashColor: Colors.white.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: widget.onPressed,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
