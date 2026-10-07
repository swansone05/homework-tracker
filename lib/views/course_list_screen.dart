import 'package:flutter/material.dart';

import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() =>
      _CourseListScreenState();
}

class _CourseListScreenState
    extends State<CourseListScreen> {
  final CoursePresenter _presenter =
      CoursePresenter();

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();

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

  Future<void> _loadCourses() async {
    try {
      await _presenter.loadCourses();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOADING COURSES: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading courses: $e',
          ),
        ),
      );
    }
  }

  Future<void> _showAddCourseDialog() async {
    String name = '';
    String description = '';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) {
                  description = value;
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
                if (name.trim().isEmpty) {
                  return;
                }

                try {
                  await _presenter.addCourse(
                    name.trim(),
                    description.trim().isEmpty
                        ? null
                        : description.trim(),
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  setState(() {});
                } catch (e) {
                  debugPrint(
                    'ERROR ADDING COURSE: $e',
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error adding course: $e',
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
  }

  @override
  Widget build(BuildContext context) {
    final courses = _presenter.courses;

    final filteredCourses = courses.where((course) {
      final query =
          _searchQuery.trim().toLowerCase();

      if (query.isEmpty) {
        return true;
      }

      final name =
          course.name.toLowerCase();

      final description =
          course.description?.toLowerCase() ?? '';

      return name.contains(query) ||
          description.contains(query);
    }).toList();

    return Scaffold(
      // IMPORTANT:
      // There is intentionally NO AppBar here.
      //
      // Your main navigation already provides
      // the "Courses" title.
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
                    controller:
                        _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search courses...',
                      prefixIcon:
                          const Icon(Icons.search),
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
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredCourses.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.trim().isEmpty
                                ? 'No courses yet.'
                                : 'No courses found.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                            bottom: 100,
                          ),
                          itemCount:
                              filteredCourses.length,
                          itemBuilder:
                              (context, index) {
                            final course =
                                filteredCourses[
                                    index];

                            return ListTile(
                              title: Text(
                                course.name,
                              ),
                              subtitle:
                                  course.description ==
                                              null ||
                                          course
                                              .description!
                                              .trim()
                                              .isEmpty
                                      ? null
                                      : Text(
                                          course
                                              .description!,
                                        ),
                            );
                          },
                        ),
                ),
              ],
            ),

      // Reusable Add button from Part 2.
      floatingActionButton: AddFAB(
        onPressed: _showAddCourseDialog,
      ),
    );
  }
}