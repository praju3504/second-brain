import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/utils/uuid_generator.dart';
import 'package:second_brain/data/repositories/task_repository_impl.dart';
import 'package:second_brain/domain/entities/task.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';
import 'package:second_brain/domain/repositories/task_repository.dart';
import 'package:second_brain/presentation/providers/database_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepositoryImpl(database);
});

final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier(ref.watch(taskRepositoryProvider));
});

final taskFilterStatusProvider = StateProvider<TaskStatus?>((ref) => null);
final taskFilterPriorityProvider = StateProvider<TaskPriority?>((ref) => null);

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  
  TasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }
  
  Future<void> loadTasks({TaskStatus? status, TaskPriority? priority}) async {
    state = const AsyncValue.loading();
    try {
      List<Task> tasks;
      if (status != null) {
        tasks = await _repository.getTasksByStatus(status);
      } else if (priority != null) {
        tasks = await _repository.getTasksByPriority(priority);
      } else {
        tasks = await _repository.getAllTasks();
      }
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
    DateTime? reminderAt,
  }) async {
    try {
      final now = DateTime.now().toTimestamp();
      final task = Task(
        id: UuidGenerator.generate(),
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate?.toTimestamp(),
        reminderAt: reminderAt?.toTimestamp(),
        createdAt: now,
        updatedAt: now,
      );
      
      await _repository.insertTask(task);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now().toTimestamp(),
      );
      await _repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> toggleComplete(String id) async {
    try {
      await _repository.completeTask(id);
      await loadTasks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<List<Task>> getUpcomingTasks(int days) async {
    return await _repository.getUpcomingTasks(days);
  }
}
