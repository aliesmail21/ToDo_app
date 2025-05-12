import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/task.dart';
import 'package:flutter_application_1/view/add_task_screen.dart';
import 'package:flutter_application_1/view/edit_task_screen.dart';
import 'package:flutter_application_1/view/calendar_screen.dart';
import 'package:flutter_application_1/services/task_storage_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _loadTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      final tasks = await TaskStorageService.loadTasks(user.uid);
      setState(() {
        _tasks = tasks;
      });
    }
  }

  Future<void> _saveTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      await TaskStorageService.saveTasks(user.uid, _tasks);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddTaskScreen(
              onTaskAdded: (task) {
                setState(() {
                  _tasks.add(task);
                });
                _saveTasks();
              },
            ),
      ),
    );
  }

  void _editTask(Task task, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditTaskScreen(
              task: task,
              onTaskUpdated: (updatedTask) {
                setState(() {
                  _tasks[index] = updatedTask;
                });
                _saveTasks();
              },
            ),
      ),
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                  _saveTasks();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTaskItem(Task task, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: task.isCompleted ? Colors.grey[100] : null,
      child: ExpansionTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            setState(() {
              task.isCompleted = value ?? false;
            });
            _saveTasks();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationThickness: 2.6,
            decorationColor: Colors.grey,
            color: task.isCompleted ? Colors.grey : null,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                decorationThickness: 2.6,
                decorationColor: Colors.grey,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: _getPriorityColor(task.priority),
                ),
                const SizedBox(width: 4),
                Text(
                  task.priority,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _editTask(task, index);
            } else if (value == 'delete') {
              _deleteTask(index);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Task'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Task', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $_userName!'),
            const Text('My Tasks', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body:
          _selectedIndex == 0
              ? _tasks.isEmpty
                  ? const Center(
                    child: Text(
                      'No tasks yet!\nTap + to add a task',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder:
                        (context, index) =>
                            _buildTaskItem(_tasks[index], index),
                  )
              : CalendarScreen(tasks: _tasks),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            label: 'Add Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          if (index == 1) {
            _addTask();
          } else {
            setState(() {
              _selectedIndex = index > 1 ? 1 : 0;
            });
          }
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
