import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:csc322upgrades2/task_model.dart';
import 'package:csc322upgrades2/new_task.dart';
import 'package:csc322upgrades2/priority.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = []; // active tasks
  List<Task> archivedTasks = []; // archived tasks
  bool showArchived = false; // false for task page, true for archived page

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

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

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> taskList = tasks.map((task) => task.toMap()).toList();
    List<Map<String, dynamic>> archivedList = archivedTasks.map((task) => task.toMap()).toList();
    prefs.setString('tasks', json.encode(taskList));
    prefs.setString('archivedTasks', json.encode(archivedList));
  }

  void _addNewTask(String title, DateTime date, Priority priority) {
    setState(() {
      tasks.add(Task(title: title, date: date, priority: priority));
      tasks.sort((a, b) => b.date.compareTo(a.date));
      _saveTasks();
    });
  }

  void _archiveTask(int index) {
    setState(() {
      archivedTasks.add(tasks[index]);
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _restoreTask(int index) {
    setState(() {
      tasks.add(archivedTasks[index]);
      archivedTasks.removeAt(index);
      _saveTasks();
    });
  }

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
            onPressed: _toggleViewArchived,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startAddNewTask(context),
          ),
        ],
      ),
      body: taskList.isEmpty
          ? Center(
              child: Text(showArchived ? 'No archived tasks.' : 'No tasks added yet.'),
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
                                _archiveTask(index);
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
                  subtitle: Text('${taskList[index].date} | Priority: ${taskList[index].priority.name.toUpperCase()}'),
                  trailing: showArchived
                      ? IconButton(
                          icon: const Icon(Icons.restore),
                          color: Colors.blue,
                          onPressed: () => _restoreTask(index),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteTask(index, false),
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
