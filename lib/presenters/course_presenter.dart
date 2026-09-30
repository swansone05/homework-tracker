import '../models/course_model.dart';

class CoursePresenter {
  final List<Course> _courses = [];

  List<Course> get courses => _courses;

  // Load courses from Firebase
  Future<void> loadCourses() async {
    final fetched = await Course.fetchCourses();

    _courses
      ..clear()
      ..addAll(fetched);
  }

  // Add a new course
  Future<void> addCourse(
    String name,
    String? description,
  ) async {
    final course = await Course.addCourse(
      name,
      description,
    );

    if (course != null) {
      _courses.add(course);
    }
  }
}