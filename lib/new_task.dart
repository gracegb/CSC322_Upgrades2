import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'priority.dart';

class NewTask extends StatefulWidget {
  final Function(String, DateTime, Priority) addTask;

  NewTask(this.addTask);

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  Priority _selectedPriority = Priority.medium;

  void _submitData() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }
    widget.addTask(_titleController.text, _selectedDate!, _selectedPriority);
    Navigator.of(context).pop();
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
