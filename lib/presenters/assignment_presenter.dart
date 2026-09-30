import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments =>
      _assignments;

  Future<void> loadAssignments() async {
    final fetched =
        await Assignment.fetchAssignments();

    _assignments
      ..clear()
      ..addAll(fetched);
  }

  Future<void> addAssignment(
    String title,
    DateTime dueDate,
  ) async {
    final assignment =
        await Assignment.addAssignment(
      title,
      dueDate,
    );

    if (assignment != null) {
      _assignments.add(assignment);
    }
  }

  Future<void> toggleCompleted(
    int index,
  ) async {
    if (index < 0 ||
        index >= _assignments.length) {
      return;
    }

    final assignment = _assignments[index];

    await Assignment.updateCompletionStatus(
      assignment,
    );

    assignment.isCompleted =
        !assignment.isCompleted;
  }

  Future<void> deleteAssignments(
    Set<int> indexes,
  ) async {
    final sortedIndexes = indexes.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndexes) {
      if (index < 0 ||
          index >= _assignments.length) {
        continue;
      }

      final assignment = _assignments[index];

      await Assignment.deleteAssignment(
        assignment,
      );

      _assignments.removeAt(index);
    }
  }
}