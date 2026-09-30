import 'package:flutter/material.dart';

import '../presenters/course_presenter.dart';

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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
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

    return Scaffold(
      // IMPORTANT:
      // There is intentionally NO AppBar here.
      //
      // Your main navigation already appears to
      // provide the "Courses" title.
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : courses.isEmpty
              ? const Center(
                  child: Text(
                    'No courses yet.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 100,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return ListTile(
                      title: Text(
                        course.name,
                      ),
                      subtitle:
                          course.description == null ||
                                  course.description!
                                      .trim()
                                      .isEmpty
                              ? null
                              : Text(
                                  course.description!,
                                ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}