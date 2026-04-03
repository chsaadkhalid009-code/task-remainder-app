import 'dart:convert';
import 'package:flutter/material.dart';

class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  TimeOfDay time;
  bool isCompleted;
  String repeatType; // 'daily', 'weekly', 'monthly'
  String category; // 'shopping', 'health', 'prayer', 'personal', 'work', 'other'
  String? notificationSound;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.time,
    this.isCompleted = false,
    required this.repeatType,
    required this.category,
    this.notificationSound,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'isCompleted': isCompleted ? 1 : 0,
      'repeatType': repeatType,
      'category': category,
      'notificationSound': notificationSound,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      isCompleted: map['isCompleted'] == 1,
      repeatType: map['repeatType'],
      category: map['category'],
      notificationSound: map['notificationSound'],
    );
  }
}

class Subtask {
  int? id;
  int taskId;
  String title;
  bool isCompleted;

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
