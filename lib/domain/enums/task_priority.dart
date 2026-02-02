enum TaskPriority {
  urgent,
  high,
  medium,
  low;
  
  String toJson() => name;
  
  static TaskPriority fromJson(String value) {
    return TaskPriority.values.firstWhere((e) => e.name == value);
  }
  
  String get displayName {
    switch (this) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
