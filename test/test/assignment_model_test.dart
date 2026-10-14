import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/models/assignment_model.dart';

void main() {
  test('New assignments should default to isCompleted = false', () {
    final assignment = Assignment(
      title: 'Test Assignment',
      courseName: 'Math',
      dueDate: DateTime(2026, 10, 20),
    );

    expect(assignment.isCompleted, false);
  });

  test('Assignment should store title and courseName correctly', () {
    final assignment = Assignment(
      title: 'Easy',
      courseName: 'English',
      dueDate: DateTime(2026, 10, 20),
    );

    expect(assignment.title, 'Easy');
    expect(assignment.courseName, 'English');
  });
}