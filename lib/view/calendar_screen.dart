import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/task.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;

  const CalendarScreen({super.key, required this.tasks});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateEvents();
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _updateEvents();
    }
  }

  void _updateEvents() {
    _events = {};
    for (var task in widget.tasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        _events.update(
          date,
          (existing) => existing..add(task),
          ifAbsent: () => [task],
        );
      }
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Color _getDayColor(DateTime day) {
    final tasks = _getTasksForDay(day);
    if (tasks.isEmpty) return Colors.transparent;

    if (tasks.any((task) => task.priority.toLowerCase() == 'high')) {
      return Colors.red.withOpacity(0.3);
    } else if (tasks.any((task) => task.priority.toLowerCase() == 'medium')) {
      return Colors.orange.withOpacity(0.3);
    } else {
      return Colors.green.withOpacity(0.3);
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getTasksForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 4,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerSize: 8,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        events.map((event) {
                          final task = event as Task;
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getPriorityColor(task.priority),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                final tasks = _getTasksForDay(day);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        tasks.isEmpty ? Colors.transparent : _getDayColor(day),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: tasks.isEmpty ? Colors.black : Colors.white,
                        fontWeight:
                            tasks.isEmpty ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _selectedDay == null
                    ? const Center(child: Text('No day selected'))
                    : ListView.builder(
                      itemCount: _getTasksForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final task = _getTasksForDay(_selectedDay!)[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.task,
                              color: _getPriorityColor(task.priority),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration:
                                    task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    task.isCompleted
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              task.priority,
                              style: TextStyle(
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
