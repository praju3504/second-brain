import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/domain/entities/task.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';
import 'package:second_brain/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;
  
  TaskRepositoryImpl(this._database);
  
  @override
  Future<List<Task>> getAllTasks() {
    return _database.taskDao.getAllTasks();
  }
  
  @override
  Future<Task?> getTaskById(String id) {
    return _database.taskDao.getTaskById(id);
  }
  
  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) {
    return _database.taskDao.getTasksByStatus(status);
  }
  
  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) {
    return _database.taskDao.getTasksByPriority(priority);
  }
  
  @override
  Future<List<Task>> getUpcomingTasks(int days) {
    return _database.taskDao.getUpcomingTasks(days);
  }
  
  @override
  Future<void> insertTask(Task task) {
    return _database.taskDao.insertTask(task);
  }
  
  @override
  Future<void> updateTask(Task task) {
    return _database.taskDao.updateTask(task);
  }
  
  @override
  Future<void> deleteTask(String id) {
    return _database.taskDao.deleteTask(id);
  }
  
  @override
  Future<void> completeTask(String id) {
    return _database.taskDao.completeTask(id);
  }
}
