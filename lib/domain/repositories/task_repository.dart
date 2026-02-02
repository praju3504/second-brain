import 'package:second_brain/domain/entities/task.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByStatus(TaskStatus status);
  Future<List<Task>> getTasksByPriority(TaskPriority priority);
  Future<List<Task>> getUpcomingTasks(int days);
  Future<void> insertTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> completeTask(String id);
}
