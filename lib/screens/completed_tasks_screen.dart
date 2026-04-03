import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/export_service.dart';

class CompletedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFBE9D7),
      appBar: AppBar(
        title: Text('Completed Tasks', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              final tasks = Provider.of<TaskProvider>(context, listen: false).completedTasks;
              if (tasks.isNotEmpty) {
                ExportService().exportToPDF(tasks, 'Completed Tasks Report');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tasks to export')));
              }
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.completedTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Text('No completed tasks yet', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                      color: isDark ? Colors.grey : Colors.grey[400],
                    ),
                  ),
                  subtitle: Text(task.category.toUpperCase(), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  trailing: IconButton(
                    icon: const Icon(Icons.undo, color: Colors.orange),
                    onPressed: () {
                      taskProvider.toggleTaskCompletion(task);
                    },
                    tooltip: 'Mark as incomplete',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
