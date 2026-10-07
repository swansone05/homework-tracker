import 'package:flutter/material.dart';

import '../alert.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

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

  final CoursePresenter _coursePresenter =
      CoursePresenter();

  final Set<int> _selectedAssignments = {};

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';

  String? _selectedCourseFilter;
  String? _newAssignmentCourse;

  List<String> _courseNames = [];

  @override
  void initState() {
    super.initState();

    _loadData();

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

  Future<void> _loadData() async {
    try {
      await _coursePresenter.loadCourses();
      await _presenter.loadAssignments();

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _courseNames = _coursePresenter.courses
            .map((course) => course.name)
            .toList();
      });
    } catch (e) {
      debugPrint(
        'ERROR LOADING ASSIGNMENTS/COURSES: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _courseNames = _coursePresenter.courses
            .map((course) => course.name)
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading assignments or courses: $e',
          ),
        ),
      );
    }
  }

  Future<void> _showAddAssignmentDialog() async {
    String title = '';
    DateTime? dueDate;

    _newAssignmentCourse =
        _courseNames.isNotEmpty
            ? _courseNames.first
            : null;

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
                    decoration: const InputDecoration(
                      hintText: 'Assignment title',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _newAssignmentCourse,
                    items: _courseNames
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _newAssignmentCourse = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (title.trim().isEmpty ||
                        dueDate == null ||
                        _newAssignmentCourse == null) {
                      return;
                    }

                    final assignmentTitle =
                        title.trim();

                    final assignmentCourse =
                        _newAssignmentCourse!;

                    final assignmentDueDate =
                        dueDate!;

                    try {
                      await _presenter.addAssignment(
                        assignmentTitle,
                        assignmentCourse,
                        assignmentDueDate,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

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

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
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
      if (_selectedAssignments.contains(index)) {
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Delete'),
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

    // Keep the original assignment indexes so
    // completion and deletion continue to work
    // correctly after filtering.
    final filteredIndexes = <int>[];

    final query =
        _searchQuery.trim().toLowerCase();

    for (int i = 0;
        i < assignments.length;
        i++) {
      final assignment = assignments[i];

      final matchesSearch =
          query.isEmpty ||
          assignment.title
              .toLowerCase()
              .contains(query);

      final matchesCourse =
          _selectedCourseFilter == null ||
          assignment.courseName ==
              _selectedCourseFilter;

      if (matchesSearch &&
          matchesCourse) {
        filteredIndexes.add(i);
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_courseNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child:
                  DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  dropdownColor:
                      Theme.of(context)
                          .colorScheme
                          .surface,
                  hint: const Text(
                    'Filter by course',
                  ),
                  value: _selectedCourseFilter,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All courses',
                      ),
                    ),
                    ..._courseNames.map(
                      (name) =>
                          DropdownMenuItem<String?>(
                        value: name,
                        child: Text(name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseFilter =
                          value;
                    });
                  },
                ),
              ),
            ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller:
                        _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search assignments...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    _searchController
                                        .clear();
                                  },
                                )
                              : null,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
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
                            final originalIndex =
                                filteredIndexes[
                                    index];

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
                                  style: TextStyle(
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
                                  'Course: '
                                  '${assignment.courseName}\n'
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

      floatingActionButton:
          isSelecting
              ? FloatingActionButton(
                  onPressed:
                      _deleteSelectedAssignments,
                  child: const Icon(
                    Icons.delete,
                  ),
                )
              : AddFAB(
                  onPressed:
                      _showAddAssignmentDialog,
                ),
    );
  }
}