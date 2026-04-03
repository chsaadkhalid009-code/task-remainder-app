import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_detail_screen.dart';

class ScheduledTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFBE9D7),
      appBar: AppBar(
        title: Text('Scheduled Tasks', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks.where((t) => !t.isCompleted).toList();

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'No scheduled tasks!', 
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 18)
              ),
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
                  leading: Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.orange,
                    onChanged: (val) => taskProvider.toggleTaskCompletion(task),
                  ),
                  title: Text(
                    task.title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    )
                  ),
                  subtitle: Text(
                    '${task.category.toUpperCase()} - ${task.dueDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () => taskProvider.deleteTask(task.id!),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
