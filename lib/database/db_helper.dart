import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/task_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;
  
  // In-memory storage for Web testing
  final List<Task> _webTasks = [];
  final List<Subtask> _webSubtasks = [];

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN category TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN time TEXT');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        dueDate TEXT,
        time TEXT,
        isCompleted INTEGER,
        repeatType TEXT,
        category TEXT,
        notificationSound TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        title TEXT,
        isCompleted INTEGER,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      task.id = _webTasks.length + 1;
      _webTasks.add(task);
      return task.id!;
    }
    final db = await database;
    return await db!.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    if (kIsWeb) return List.from(_webTasks);
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    if (kIsWeb) {
      int index = _webTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _webTasks[index] = task;
      return 1;
    }
    final db = await database;
    return await db!.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      _webTasks.removeWhere((t) => t.id == id);
      _webSubtasks.removeWhere((s) => s.taskId == id);
      return 1;
    }
    final db = await database;
    await db!.delete('subtasks', where: 'taskId = ?', whereArgs: [id]);
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertSubtask(Subtask subtask) async {
    if (kIsWeb) {
      subtask.id = _webSubtasks.length + 1;
      _webSubtasks.add(subtask);
      return subtask.id!;
    }
    final db = await database;
    return await db!.insert('subtasks', subtask.toMap());
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    if (kIsWeb) return _webSubtasks.where((s) => s.taskId == taskId).toList();
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    return List.generate(maps.length, (i) => Subtask.fromMap(maps[i]));
  }

  Future<int> updateSubtask(Subtask subtask) async {
    if (kIsWeb) {
      int index = _webSubtasks.indexWhere((s) => s.id == subtask.id);
      if (index != -1) _webSubtasks[index] = subtask;
      return 1;
    }
    final db = await database;
    return await db!.update('subtasks', subtask.toMap(), where: 'id = ?', whereArgs: [subtask.id]);
  }
}
