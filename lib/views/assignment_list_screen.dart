import 'package:flutter/material.dart';

import '../alert.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter =
      AssignmentPresenter();

  final Set<int> _selectedAssignments = {};

  void _showAddAssignmentDialog() {
    String title = '';
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Assignment title',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      dueDate == null
                          ? 'Select due date'
                          : '${dueDate!.month}/${dueDate!.day}/${dueDate!.year}',
                    ),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (selectedDate != null) {
                        setDialogState(() {
                          dueDate = selectedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.trim().isEmpty || dueDate == null) {
                      return;
                    }

                    setState(() {
                      _presenter.addAssignment(
                        title.trim(),
                        dueDate!,
                      );
                    });

                    Navigator.pop(context);

                    _checkDueDate(
                      title.trim(),
                      dueDate!,
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkDueDate(
    String title,
    DateTime dueDate,
  ) {
    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final dueDateOnly = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final daysUntilDue =
        dueDateOnly.difference(todayOnly).inDays;

    if (daysUntilDue == 0 ||
        daysUntilDue == 1 ||
        daysUntilDue == 3) {
      showDueDateAlert(
        context,
        title,
        daysUntilDue,
      );
    }
  }

  void _toggleAssignmentCompletion(int index) {
    setState(() {
      _presenter.toggleCompleted(index);
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAssignments.contains(index)) {
        _selectedAssignments.remove(index);
      } else {
        _selectedAssignments.add(index);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedAssignments.clear();
    });
  }

  Future<void> _deleteSelectedAssignments() async {
    if (_selectedAssignments.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete assignments?'),
          content: Text(
            'Are you sure you want to delete '
            '${_selectedAssignments.length} '
            'selected assignment(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _presenter.deleteAssignments(
          _selectedAssignments,
        );

        _selectedAssignments.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;
    final isSelecting = _selectedAssignments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSelecting
              ? '${_selectedAssignments.length} selected'
              : 'Assignments',
        ),
        leading: isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedAssignments,
                ),
              ]
            : null,
      ),
      body: assignments.isEmpty
          ? const Center(
              child: Text('No assignments yet.'),
            )
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final isSelected =
                    _selectedAssignments.contains(index);

                return GestureDetector(
                  onLongPress: () {
                    _toggleSelection(index);
                  },
                  child: CheckboxListTile(
                    selected: isSelected,
                    title: Text(
                      assignment.title,
                      style: TextStyle(
                        decoration: assignment.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      'Due: '
                      '${assignment.dueDate.month}/'
                      '${assignment.dueDate.day}/'
                      '${assignment.dueDate.year}',
                    ),
                    value: assignment.isCompleted,
                    onChanged: (_) {
                      if (isSelecting) {
                        _toggleSelection(index);
                      } else {
                        _toggleAssignmentCompletion(index);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: isSelecting
          ? null
          : FloatingActionButton(
              onPressed: _showAddAssignmentDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}