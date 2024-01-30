class Task {
  bool isChecked;
  final String time;
  final String title;
  final String description;
  final bool isUrgent;
  final String dueDate;
  final String endDate;
  String audioPath;
  final DateTime creationDate;
  final String selectedTimeOfDay;

  Task({
    required this.time,
    this.isChecked = false,
    required this.title,
    required this.description,
    required this.isUrgent,
    required this.dueDate,
    required this.endDate,
    required this.audioPath,
    required this.creationDate,
    required this.selectedTimeOfDay,
  });
}
