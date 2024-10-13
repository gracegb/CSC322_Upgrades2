import 'package:csc322upgrades2/new_task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); 
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      List<dynamic> taskList = json.decode(tasksData);
      setState(() {
        tasks = taskList.map((item) => Task.fromMap(item)).toList();
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> taskList = tasks.map((task) => task.toMap()).toList();
    prefs.setString('tasks', json.encode(taskList));
  }

  void _addNewTask(String title, DateTime date) {
    setState(() {
      tasks.add(Task(title: title, date: date));
      tasks.sort((a, b) => b.date.compareTo(a.date));
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startAddNewTask(context),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks added yet.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].completed,
                    onChanged: (bool? value) {
                      setState(() {
                        tasks[index].completed = value!;
                        _saveTasks();
                      });
                    },
                  ),
                  title: Text(
                    tasks[index].title,
                    style: TextStyle(
                      decoration: tasks[index].completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(tasks[index].date.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
    );
  }

  void _startAddNewTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTask(_addNewTask),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }
}

class Task {
  final String title;
  final DateTime date;
  bool completed;

  Task({required this.title, required this.date, this.completed = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      date: DateTime.parse(map['date']),
      completed: map['completed'],
    );
  }
}
