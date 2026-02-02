import 'package:equatable/equatable.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final int? dueDate;
  final int? reminderAt;
  final int? completedAt;
  final int? timeEstimate;
  final int? timeSpent;
  final int createdAt;
  final int updatedAt;
  
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.reminderAt,
    this.completedAt,
    this.timeEstimate,
    this.timeSpent,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    int? dueDate,
    int? reminderAt,
    int? completedAt,
    int? timeEstimate,
    int? timeSpent,
    int? createdAt,
    int? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      completedAt: completedAt ?? this.completedAt,
      timeEstimate: timeEstimate ?? this.timeEstimate,
      timeSpent: timeSpent ?? this.timeSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id, title, description, status, priority, dueDate, reminderAt,
    completedAt, timeEstimate, timeSpent, createdAt, updatedAt,
  ];
}
