import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csc322upgrades2/priority.dart';

class NewTask extends StatefulWidget {
  final Function(String, DateTime) addTask;

  NewTask(this.addTask);

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  Priority _selectedPriority = Priority.medium; // default priority

  void _submitData() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }
    widget.addTask(_titleController.text, _selectedDate!);
    Navigator.of(context).pop(); // Close modal
  }

  void _presentDatePicker() {
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
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Date'),
                ),
              ],
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
