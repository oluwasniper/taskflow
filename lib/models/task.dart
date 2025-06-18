// lib/models/task.dart

// Enum for task priorities
enum Priority { Low, Medium, High }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  Priority priority;
  List<String> tags;
  int satisfactionRating; // 0 for not rated, 1-5 for rated

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = Priority.Medium,
    this.tags = const [],
    this.satisfactionRating = 0,
  });

  String get priorityString {
    switch (priority) {
      case Priority.High:
        return 'High';
      case Priority.Medium:
        return 'Medium';
      case Priority.Low:
        return 'Low';
    }
  }

  // Convert a Task object into a Map for sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(), // Store dates as text
      'isCompleted': isCompleted ? 1 : 0, // Store booleans as 0 or 1
      'priority': priority.index, // Store enums as their index
      'tags': tags.join(','), // Store lists as a single string
      'satisfactionRating': satisfactionRating,
    };
  }

  // Create a Task object from a Map from sqflite
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      priority: Priority.values[map['priority']],
      // Split the string by the delimiter to get the list back
      tags: map['tags'].isEmpty ? [] : (map['tags'] as String).split(','),
      satisfactionRating: map['satisfactionRating'],
    );
  }

  // --- Add this copyWith method ---
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    Priority? priority,
    List<String>? tags,
    int? satisfactionRating,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
    );
  }
}

// Enum to represent the different task filtering options.
enum TaskFilter {
  all,
  pending,
  completed;

  // A computed property to get a user-friendly display name for each filter.
  String get displayName {
    switch (this) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}
