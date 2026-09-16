import 'package:flutter/material.dart';

import '../presenters/course_presenter.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() =>
      _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursePresenter _presenter = CoursePresenter();

  void _showAddCourseDialog() {
    String name = '';
    String? description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter course name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter course description (optional)',
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
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.trim().isEmpty) {
                  return;
                }

                setState(() {
                  _presenter.addCourse(
                    name.trim(),
                    description?.trim(),
                  );
                });

                Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text('No courses yet.'),
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(course.name),
                  subtitle: course.description != null &&
                          course.description!.isNotEmpty
                      ? Text(course.description!)
                      : null,
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