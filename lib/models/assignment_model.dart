import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String? id;
  final String title;
  final DateTime dueDate;
  bool isCompleted;

  Assignment({
    this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory Assignment.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final dueDateValue = data['dueDate'];

    DateTime parsedDueDate;

    if (dueDateValue is int) {
      parsedDueDate =
          DateTime.fromMillisecondsSinceEpoch(
        dueDateValue,
      );
    } else {
      parsedDueDate =
          DateTime.tryParse(
            dueDateValue?.toString() ?? '',
          ) ??
          DateTime.now();
    }

    return Assignment(
      id: id,
      title: data['title']?.toString() ?? '',
      dueDate: parsedDueDate,
      isCompleted: data['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static final DatabaseReference _database =
      FirebaseDatabase.instance.ref();

  static Future<List<Assignment>>
      fetchAssignments() async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'ASSIGNMENTS: NO USER LOGGED IN',
      );
      return [];
    }

    debugPrint(
      'ASSIGNMENTS: CURRENT USER UID = ${user.uid}',
    );

    try {
      debugPrint(
        'ASSIGNMENTS: READING FROM assignments/${user.uid}',
      );

      final snapshot = await _database
          .child('assignments')
          .child(user.uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'ASSIGNMENTS: DATABASE READ SUCCESSFUL',
      );

      if (!snapshot.exists ||
          snapshot.value == null) {
        debugPrint(
          'ASSIGNMENTS: NO ASSIGNMENTS FOUND',
        );
        return [];
      }

      final assignments = <Assignment>[];

      if (snapshot.value is! Map) {
        debugPrint(
          'ASSIGNMENTS: UNEXPECTED DATABASE FORMAT',
        );
        return [];
      }

      final data =
          Map<dynamic, dynamic>.from(
        snapshot.value as Map,
      );

      data.forEach((key, value) {
        if (value is Map) {
          assignments.add(
            Assignment.fromMap(
              key.toString(),
              Map<String, dynamic>.from(value),
            ),
          );
        }
      });

      debugPrint(
        'ASSIGNMENTS: FOUND ${assignments.length} ASSIGNMENTS',
      );

      return assignments;
    } catch (e) {
      debugPrint(
        'ASSIGNMENTS: ERROR LOADING = $e',
      );

      rethrow;
    }
  }

  static Future<Assignment?>
      addAssignment(
    String title,
    DateTime dueDate,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        'ASSIGNMENTS: CANNOT ADD - NO USER LOGGED IN',
      );
      return null;
    }

    debugPrint(
      'ASSIGNMENTS: ADDING FOR USER ${user.uid}',
    );

    try {
      final newAssignmentRef = _database
          .child('assignments')
          .child(user.uid)
          .push();

      final assignment = Assignment(
        id: newAssignmentRef.key,
        title: title,
        dueDate: dueDate,
        isCompleted: false,
      );

      await newAssignmentRef
          .set(assignment.toMap())
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        'ASSIGNMENTS: ADDED SUCCESSFULLY',
      );

      return assignment;
    } catch (e) {
      debugPrint(
        'ASSIGNMENTS: ERROR ADDING = $e',
      );

      rethrow;
    }
  }

  static Future<void>
      updateCompletionStatus(
    Assignment assignment,
  ) async {
    final user = _auth.currentUser;

    if (user == null ||
        assignment.id == null) {
      return;
    }

    try {
      await _database
          .child('assignments')
          .child(user.uid)
          .child(assignment.id!)
          .update({
        'isCompleted':
            !assignment.isCompleted,
      }).timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint(
        'ASSIGNMENTS: ERROR UPDATING = $e',
      );

      rethrow;
    }
  }

  static Future<void>
      deleteAssignment(
    Assignment assignment,
  ) async {
    final user = _auth.currentUser;

    if (user == null ||
        assignment.id == null) {
      return;
    }

    try {
      await _database
          .child('assignments')
          .child(user.uid)
          .child(assignment.id!)
          .remove()
          .timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint(
        'ASSIGNMENTS: ERROR DELETING = $e',
      );

      rethrow;
    }
  }
}