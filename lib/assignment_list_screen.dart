import 'package:flutter/material.dart';
import 'alert.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final List<Map<String, dynamic>> _assignments = [];

  void _showAddAssignmentDialog() {
    String title = '';
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Assignment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter assignment title',
                  ),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                const SizedBox(height: 15),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    dueDate == null
                        ? 'Choose due date'
                        : 'Due ${dueDate!.month}/${dueDate!.day}/${dueDate!.year}',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (date != null) {
                      setDialogState(() {
                        dueDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.trim().isNotEmpty && dueDate != null) {
                    setState(() {
                      _assignments.add({
                        'title': title.trim(),
                        'dueDate': dueDate,
                        'isCompleted': false,
                      });
                    });

                    Navigator.pop(context);

                    _checkDueDate(
                      title.trim(),
                      dueDate!,
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkDueDate(String title, DateTime dueDate) {
    final today = DateTime.now();

    final daysUntilDue = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    ).difference(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    ).inDays;

    if (daysUntilDue == 3) {
      showDueDateAlert(
        context,
        title,
        daysUntilDue,
      );
    }
  }

  String _getDueDateText(DateTime dueDate) {
    final today = DateTime.now();

    final difference = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    ).difference(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    ).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else if (difference == -1) {
      return '1 day overdue';
    } else {
      return '${difference.abs()} days overdue';
    }
  }

  void _toggleAssignmentCompletion(int index) {
    setState(() {
      _assignments[index]['isCompleted'] =
          !_assignments[index]['isCompleted'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: _assignments.isEmpty
          ? const Center(
              child: Text('No assignments yet.'),
            )
          : ListView.builder(
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                final dueDate =
                    assignment['dueDate'] as DateTime;

                return ListTile(
                  title: Text(
                    assignment['title'],
                    style: TextStyle(
                      decoration: assignment['isCompleted']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    _getDueDateText(dueDate),
                  ),
                  trailing: Checkbox(
                    value: assignment['isCompleted'],
                    onChanged: (_) {
                      _toggleAssignmentCompletion(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}