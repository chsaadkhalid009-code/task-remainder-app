import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _subtaskController = TextEditingController();
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  void _loadSubtasks() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final subtasks = await provider.getSubtasks(widget.task.id!);
    setState(() {
      _subtasks = subtasks;
    });
  }

  void _addSubtask() async {
    if (_subtaskController.text.isNotEmpty) {
      final subtask = Subtask(
        taskId: widget.task.id!,
        title: _subtaskController.text,
      );
      await Provider.of<TaskProvider>(context, listen: false).addSubtask(subtask);
      _subtaskController.clear();
      _loadSubtasks();
    }
  }

  double _calculateProgress() {
    if (_subtasks.isEmpty) return 0.0;
    final completed = _subtasks.where((s) => s.isCompleted).length;
    return completed / _subtasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(task: widget.task),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.task.id!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.task.description.isEmpty ? 'No description' : widget.task.description),
            SizedBox(height: 10),
            Text('Due Date: ${widget.task.dueDate.toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 20),
            Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(height: 20),
            Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _subtasks.isEmpty 
                ? Center(child: Text('No subtasks yet'))
                : ListView.builder(
                    itemCount: _subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = _subtasks[index];
                      return CheckboxListTile(
                        title: Text(subtask.title),
                        value: subtask.isCompleted,
                        onChanged: (val) async {
                          await Provider.of<TaskProvider>(context, listen: false)
                              .toggleSubtaskCompletion(subtask);
                          _loadSubtasks();
                        },
                      );
                    },
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: InputDecoration(
                        hintText: 'Add a subtask...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32),
                    onPressed: _addSubtask,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
