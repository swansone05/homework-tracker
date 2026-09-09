import 'package:flutter/material.dart';

void showDueDateAlert(
  BuildContext context,
  String assignmentTitle,
  int daysUntilDue,
) {
  String message;

  if (daysUntilDue == 0) {
    message = '$assignmentTitle is due today!';
  } else if (daysUntilDue == 1) {
    message = '$assignmentTitle is due tomorrow!';
  } else {
    message = '$assignmentTitle is due in $daysUntilDue days.';
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upcoming Assignment'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}