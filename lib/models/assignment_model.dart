class Assignment {
  final String title;
  final DateTime dueDate;
  bool isCompleted;

  Assignment({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}