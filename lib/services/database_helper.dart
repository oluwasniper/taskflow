// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "TaskFlow.db";
  static const _databaseVersion = 1;

  static const table = 'tasks'; // Table name

  // Column names
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnDueDate = 'dueDate';
  static const columnPriority = 'priority';
  static const columnIsCompleted = 'isCompleted';
  static const columnTags = 'tags';
  static const columnSatisfactionRating = 'satisfactionRating';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database or create it if it doesn't exist.
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnDueDate TEXT NOT NULL,
            $columnPriority INTEGER NOT NULL,
            $columnIsCompleted INTEGER NOT NULL,
            $columnTags TEXT NOT NULL,
            $columnSatisfactionRating INTEGER NOT NULL
          )
          ''');
  }

  // You might add upgrade/downgrade logic here if your schema changes
}
