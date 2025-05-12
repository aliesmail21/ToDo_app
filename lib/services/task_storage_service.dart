import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/model/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'user_tasks_';

  // Save tasks for a specific user
  static Future<void> saveTasks(String userId, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toMap()).toList();
    await prefs.setString(_tasksKey + userId, jsonEncode(tasksJson));
  }

  // Load tasks for a specific user
  static Future<List<Task>> loadTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey + userId);

    if (tasksJson == null) {
      return [];
    }

    final List<dynamic> decodedTasks = jsonDecode(tasksJson);
    return decodedTasks.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  // Clear tasks for a specific user
  static Future<void> clearTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey + userId);
  }
}
