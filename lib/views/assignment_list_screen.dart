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

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    try {
      await _presenter.loadAssignments();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR LOADING ASSIGNMENTS: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading assignments: $e',
          ),
        ),
      );
    }
  }

  Future<void> _showAddAssignmentDialog() async {
    String title = '';
    DateTime? dueDate;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Assignment',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Assignment title',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                    ),
                    title: Text(
                      dueDate == null
                          ? 'Select due date'
                          : '${dueDate!.month}/'
                              '${dueDate!.day}/'
                              '${dueDate!.year}',
                    ),
                    onTap: () async {
                      final selectedDate =
                          await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now(),
                        firstDate:
                            DateTime.now(),
                        lastDate:
                            DateTime(2100),
                      );

                      if (selectedDate != null) {
                        setDialogState(() {
                          dueDate =
                              selectedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.trim().isEmpty ||
                        dueDate == null) {
                      return;
                    }

                    final assignmentTitle =
                        title.trim();

                    final assignmentDueDate =
                        dueDate!;

                    try {
                      await _presenter
                          .addAssignment(
                        assignmentTitle,
                        assignmentDueDate,
                      );

                      if (!mounted) return;

                      Navigator.pop(
                        dialogContext,
                      );

                      setState(() {});

                      _checkDueDate(
                        assignmentTitle,
                        assignmentDueDate,
                      );
                    } catch (e) {
                      debugPrint(
                        'ERROR ADDING ASSIGNMENT: $e',
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding assignment: $e',
                          ),
                        ),
                      );
                    }
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
        dueDateOnly
            .difference(todayOnly)
            .inDays;

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

  Future<void> _toggleAssignmentCompletion(
    int index,
  ) async {
    try {
      await _presenter.toggleCompleted(index);

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      debugPrint(
        'ERROR UPDATING ASSIGNMENT: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating assignment: $e',
          ),
        ),
      );
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAssignments
          .contains(index)) {
        _selectedAssignments.remove(index);
      } else {
        _selectedAssignments.add(index);
      }
    });
  }

  Future<void> _deleteSelectedAssignments() async {
    if (_selectedAssignments.isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete assignments?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${_selectedAssignments.length} '
            'selected assignment(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _presenter.deleteAssignments(
        _selectedAssignments,
      );

      if (!mounted) return;

      setState(() {
        _selectedAssignments.clear();
      });
    } catch (e) {
      debugPrint(
        'ERROR DELETING ASSIGNMENTS: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting assignments: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments =
        _presenter.assignments;

    final isSelecting =
        _selectedAssignments.isNotEmpty;

    // Create a list of the ORIGINAL assignment
    // indexes that match the search.
    //
    // This is important because the presenter
    // still expects the original assignment index
    // when completing/deleting assignments.
    final filteredIndexes =
        <int>[];

    final query =
        _searchQuery.trim().toLowerCase();

    for (int i = 0;
        i < assignments.length;
        i++) {
      final assignment = assignments[i];

      if (query.isEmpty ||
          assignment.title
              .toLowerCase()
              .contains(query)) {
        filteredIndexes.add(i);
      }
    }

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search assignments...',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    _searchController
                                        .clear();
                                  },
                                )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredIndexes.isEmpty
                      ? Center(
                          child: Text(
                            assignments.isEmpty
                                ? 'No assignments yet.'
                                : 'No assignments found.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                            bottom: 100,
                          ),
                          itemCount:
                              filteredIndexes.length,
                          itemBuilder:
                              (context, index) {
                            // Get the ORIGINAL index.
                            final originalIndex =
                                filteredIndexes[index];

                            final assignment =
                                assignments[
                                    originalIndex];

                            final isSelected =
                                _selectedAssignments
                                    .contains(
                              originalIndex,
                            );

                            return GestureDetector(
                              onLongPress: () {
                                _toggleSelection(
                                  originalIndex,
                                );
                              },
                              child:
                                  CheckboxListTile(
                                selected:
                                    isSelected,
                                title: Text(
                                  assignment.title,
                                  style:
                                      TextStyle(
                                    decoration:
                                        assignment
                                                .isCompleted
                                            ? TextDecoration
                                                .lineThrough
                                            : TextDecoration
                                                .none,
                                  ),
                                ),
                                subtitle: Text(
                                  'Due: '
                                  '${assignment.dueDate.month}/'
                                  '${assignment.dueDate.day}/'
                                  '${assignment.dueDate.year}',
                                ),
                                value: assignment
                                    .isCompleted,
                                onChanged: (_) {
                                  if (isSelecting) {
                                    _toggleSelection(
                                      originalIndex,
                                    );
                                  } else {
                                    _toggleAssignmentCompletion(
                                      originalIndex,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: isSelecting
          ? FloatingActionButton(
              onPressed:
                  _deleteSelectedAssignments,
              child: const Icon(
                Icons.delete,
              ),
            )
          : FloatingActionButton(
              onPressed:
                  _showAddAssignmentDialog,
              child: const Icon(
                Icons.add,
              ),
            ),
    );
  }
}