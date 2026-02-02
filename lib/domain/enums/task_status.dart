enum TaskStatus {
  todo,
  inProgress,
  done,
  cancelled;
  
  String toJson() => name;
  
  static TaskStatus fromJson(String value) {
    return TaskStatus.values.firstWhere((e) => e.name == value);
  }
  
  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}
