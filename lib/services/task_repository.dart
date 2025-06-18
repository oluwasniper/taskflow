import 'package:taskflow/models/task.dart';
import 'package:taskflow/services/database_helper.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  final dbHelper = DatabaseHelper.instance;
  final uuid = Uuid();

  Future<void> insertTask(Task task) async {
    if (task.title.isEmpty) {
      throw Exception('Task title cannot be empty');
    }

    try {
      final db = await dbHelper.database;
      final taskWithId = Task(
        id: uuid.v4(),
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        priority: task.priority,
        tags: task.tags,
      );
      await db.insert(DatabaseHelper.table, taskWithId.toMap());
    } catch (e) {
      throw Exception('Failed to insert task: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.table,
      );
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id.isEmpty) {
      throw Exception('Task ID cannot be empty');
    }

    try {
      final db = await dbHelper.database;
      await db.update(
        DatabaseHelper.table,
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    if (id.isEmpty) {
      throw Exception('Task ID cannot be empty');
    }

    try {
      final db = await dbHelper.database;
      await db.delete(DatabaseHelper.table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
