class User {
  String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String expetedTaskDuration;
  bool completed;

  User({
    this.id = '',
    required this.title,
    required this.description,
    required this.deadline,
    required this.expetedTaskDuration,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'description': description,
        'Deadline': deadline.toIso8601String(), // Convert to string
        'ExpetedTaskDuration': expetedTaskDuration,
        'completed': completed,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        title: json['name'],
        description: json['description'],
        deadline: DateTime.parse(json['Deadline']), // Parse from string
        expetedTaskDuration: json['ExpetedTaskDuration'],
        completed: json['completed'],
      );
}
