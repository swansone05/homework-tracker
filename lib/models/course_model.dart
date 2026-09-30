import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Course {
  final String? id;
  final String name;
  final String? description;

  Course({
    this.id,
    required this.name,
    this.description,
  });

  factory Course.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Course(
      id: document.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // Load courses belonging to the logged-in user
  static Future<List<Course>> fetchCourses() async {
    final user = _auth.currentUser;

    // Check if someone is logged in
    if (user == null) {
      debugPrint('NO USER IS LOGGED IN');
      return [];
    }

    // Show the current user's Firebase UID
    debugPrint(
      'CURRENT USER UID: ${user.uid}',
    );

    try {
      final snapshot = await _firestore
          .collection('courses')
          .where(
            'userId',
            isEqualTo: user.uid,
          )
          .get()
          .timeout(
            const Duration(seconds: 10),
          );

      // Show how many courses were found
      debugPrint(
        'COURSES FOUND: ${snapshot.docs.length}',
      );

      // Show each course returned by Firebase
      for (final document in snapshot.docs) {
        debugPrint(
          'COURSE DATA: ${document.data()}',
        );
      }

      return snapshot.docs
          .map(
            (document) =>
                Course.fromFirestore(document),
          )
          .toList();
    } catch (e) {
      debugPrint(
        'ERROR FETCHING COURSES: $e',
      );

      rethrow;
    }
  }

  // Add a course for the logged-in user
  static Future<Course?> addCourse(
    String name,
    String? description,
  ) async {
    final user = _auth.currentUser;

    // Check if someone is logged in
    if (user == null) {
      debugPrint(
        'CANNOT ADD COURSE: NO USER IS LOGGED IN',
      );
      return null;
    }

    debugPrint(
      'ADDING COURSE FOR USER: ${user.uid}',
    );

    try {
      final document =
          await _firestore.collection('courses').add({
        'name': name,
        'description': description,
        'userId': user.uid,
      });

      debugPrint(
        'COURSE ADDED SUCCESSFULLY',
      );

      debugPrint(
        'NEW COURSE DOCUMENT ID: ${document.id}',
      );

      return Course(
        id: document.id,
        name: name,
        description: description,
      );
    } catch (e) {
      debugPrint(
        'ERROR ADDING COURSE: $e',
      );

      rethrow;
    }
  }
}