import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  ThemeMode _themeMode = ThemeMode.light;

  List<Task> get tasks => _tasks;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  // Added this getter to fix the error in repeated_tasks_screen.dart
  List<Task> get repeatedTasks => _tasks.where((task) => task.repeatType != 'never' && !task.isCompleted).toList();

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category && !task.isCompleted).toList();
  }

  Future<void> loadTasks() async {
    _tasks = await DBHelper().getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    int id = await DBHelper().insertTask(task);
    task.id = id;
    _scheduleNotifications(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await DBHelper().updateTask(task);
    _scheduleNotifications(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DBHelper().deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }

  void _scheduleNotifications(Task task) {
    if (task.isCompleted) return;

    final scheduledTime = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
      task.time.hour,
      task.time.minute,
    );

    if (scheduledTime.isAfter(DateTime.now())) {
      NotificationService().scheduleNotification(
        task.id!,
        'Task Starting Now!',
        'It is time for: ${task.title}',
        scheduledTime,
      );

      final fiveMinBefore = scheduledTime.subtract(const Duration(minutes: 5));
      if (fiveMinBefore.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          task.id! + 10000,
          'Upcoming Task (5 min)',
          'Reminder: ${task.title} starts in 5 minutes.',
          fiveMinBefore,
        );
      }
    }
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    return await DBHelper().getSubtasks(taskId);
  }

  Future<void> addSubtask(Subtask subtask) async {
    await DBHelper().insertSubtask(subtask);
    notifyListeners();
  }

  Future<void> toggleSubtaskCompletion(Subtask subtask) async {
    subtask.isCompleted = !subtask.isCompleted;
    await DBHelper().updateSubtask(subtask);
    notifyListeners();
  }
}
