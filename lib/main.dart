import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csc322upgrades2/priority.dart';


void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const TaskPage(),
    );
  }
}

// Main TaskPage widget
class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = []; // Active tasks
  List<Task> archivedTasks = []; // Archived/completed tasks
  bool showArchived = false; // Toggle to view archived tasks

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    String? archivedData = prefs.getString('archivedTasks');
    
    if (tasksData != null) {
      List<dynamic> taskList = json.decode(tasksData);
      setState(() {
        tasks = taskList.map((item) => Task.fromMap(item)).toList();
      });
    }
    if (archivedData != null) {
      List<dynamic> archivedList = json.decode(archivedData);
      setState(() {
        archivedTasks = archivedList.map((item) => Task.fromMap(item)).toList();
      });
    }
  }

  // Save tasks and archived tasks to SharedPreferences
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> taskList = tasks.map((task) => task.toMap()).toList();
    List<Map<String, dynamic>> archivedList = archivedTasks.map((task) => task.toMap()).toList();
    prefs.setString('tasks', json.encode(taskList));
    prefs.setString('archivedTasks', json.encode(archivedList));
  }

  // Add a new task
  void _addNewTask(String title, DateTime date, Priority priority) {
    setState(() {
      tasks.add(Task(title: title, date: date, priority: priority));
      tasks.sort((a, b) => b.date.compareTo(a.date)); // Sort tasks by date
      _saveTasks();
    });
  }

  // Archive (complete) a task
  void _archiveTask(int index) {
    setState(() {
      archivedTasks.add(tasks[index]);
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  // Restore an archived task back to active tasks
  void _restoreTask(int index) {
    setState(() {
      tasks.add(archivedTasks[index]);
      archivedTasks.removeAt(index);
      _saveTasks();
    });
  }

  // Delete a task (from either active or archived)
  void _deleteTask(int index, bool isArchived) {
    setState(() {
      if (isArchived) {
        archivedTasks.removeAt(index);
      } else {
        tasks.removeAt(index);
      }
      _saveTasks();
    });
  }

  // Toggle between viewing active or archived tasks
  void _toggleViewArchived() {
    setState(() {
      showArchived = !showArchived;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskList = showArchived ? archivedTasks : tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(showArchived ? Icons.unarchive : Icons.archive),
            onPressed: _toggleViewArchived, // Toggle archive view
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startAddNewTask(context),
          ),
        ],
      ),
      body: taskList.isEmpty
          ? Center(
              child: Text(showArchived
                  ? 'No archived tasks.'
                  : 'No tasks added yet.'), // Different message for empty archived tasks
            )
          : ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  leading: Checkbox(
                    value: taskList[index].completed,
                    onChanged: showArchived
                        ? null
                        : (bool? value) {
                            setState(() {
                              taskList[index].completed = value!;
                              if (taskList[index].completed) {
                                _archiveTask(index); // Archive when marked complete
                              }
                              _saveTasks();
                            });
                          },
                  ),
                  title: Text(
                    taskList[index].title,
                    style: TextStyle(
                      decoration: taskList[index].completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                      '${taskList[index].date} | Priority: ${taskList[index].priority.name.toUpperCase()}'),
                  trailing: showArchived
                      ? IconButton(
                          icon: const Icon(Icons.restore),
                          color: Colors.blue,
                          onPressed: () => _restoreTask(index), // Restore archived task
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteTask(index, false), // Delete active task
                        ),
                );
              },
            ),
    );
  }

  // Start adding a new task (show modal)
  void _startAddNewTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTask(_addNewTask), // Pass the function to add a new task
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }
}

// Task class representing each task
class Task {
  final String title;
  final DateTime date;
  bool completed;
  final Priority priority; // Priority added

  Task({
    required this.title,
    required this.date,
    this.completed = false,
    required this.priority, // Required field for priority
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'completed': completed,
      'priority': priority.index, // Store priority as an integer
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      date: DateTime.parse(map['date']),
      completed: map['completed'],
      priority: Priority.values[map['priority']], // Retrieve priority from integer
    );
  }
}

// Widget for adding a new task
class NewTask extends StatefulWidget {
  final Function(String, DateTime, Priority) addTask;

  NewTask(this.addTask);

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  Priority _selectedPriority = Priority.medium; // Default priority

  void _submitData() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }
    widget.addTask(_titleController.text, _selectedDate!, _selectedPriority);
    Navigator.of(context).pop(); // Close modal
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onSubmitted: (_) => _submitData(),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Chosen!'
                        : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    ).then((pickedDate) {
                      if (pickedDate == null) {
                        return;
                      }
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    });
                  },
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            DropdownButton<Priority>(
              value: _selectedPriority,
              items: Priority.values.map((Priority priority) {
                return DropdownMenuItem<Priority>(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (Priority? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
