import 'package:drift/drift.dart';
import 'package:second_brain/data/database/app_database.dart';
import 'package:second_brain/data/database/tables/entities_table.dart';
import 'package:second_brain/data/database/tables/tasks_table.dart';
import 'package:second_brain/domain/entities/task.dart';
import 'package:second_brain/domain/enums/entity_type.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Entities, Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);
  
  Future<List<Task>> getAllTasks() async {
    final query = select(entities).join([
      innerJoin(tasks, tasks.entityId.equalsExp(entities.id)),
    ])..where(entities.entityType.equals(EntityType.task.name) & entities.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(entities.createdAt)]);
    
    final results = await query.get();
    return results.map((row) => _mapToTask(row)).toList();
  }
  
  Future<Task?> getTaskById(String id) async {
    final query = select(entities).join([
      innerJoin(tasks, tasks.entityId.equalsExp(entities.id)),
    ])..where(entities.id.equals(id) & entities.deletedAt.isNull());
    
    final results = await query.get();
    if (results.isEmpty) return null;
    return _mapToTask(results.first);
  }
  
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final query = select(entities).join([
      innerJoin(tasks, tasks.entityId.equalsExp(entities.id)),
    ])..where(
      (entities.entityType.equals(EntityType.task.name) & entities.deletedAt.isNull()) &
      tasks.status.equals(status.name)
    )..orderBy([OrderingTerm.desc(entities.createdAt)]);
    
    final results = await query.get();
    return results.map((row) => _mapToTask(row)).toList();
  }
  
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final query = select(entities).join([
      innerJoin(tasks, tasks.entityId.equalsExp(entities.id)),
    ])..where(
      (entities.entityType.equals(EntityType.task.name) & entities.deletedAt.isNull()) &
      tasks.priority.equals(priority.name)
    )..orderBy([OrderingTerm.desc(entities.createdAt)]);
    
    final results = await query.get();
    return results.map((row) => _mapToTask(row)).toList();
  }
  
  Future<List<Task>> getUpcomingTasks(int days) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final futureDate = DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch ~/ 1000;
    
    final query = select(entities).join([
      innerJoin(tasks, tasks.entityId.equalsExp(entities.id)),
    ])..where(
      (entities.entityType.equals(EntityType.task.name) & entities.deletedAt.isNull()) &
      tasks.dueDate.isBetweenValues(now, futureDate) &
      tasks.status.equals(TaskStatus.todo.name) | tasks.status.equals(TaskStatus.inProgress.name)
    )..orderBy([OrderingTerm.asc(tasks.dueDate)]);
    
    final results = await query.get();
    return results.map((row) => _mapToTask(row)).toList();
  }
  
  Future<void> insertTask(Task task) async {
    await into(entities).insert(
      EntitiesCompanion.insert(
        id: task.id,
        entityType: EntityType.task.name,
        title: task.title,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      ),
    );
    
    await into(tasks).insert(
      TasksCompanion.insert(
        entityId: task.id,
        status: task.status.name,
        priority: task.priority.name,
        description: Value(task.description),
        dueDate: Value(task.dueDate),
        reminderAt: Value(task.reminderAt),
        timeEstimate: Value(task.timeEstimate),
        timeSpent: Value(task.timeSpent),
        completedAt: Value(task.completedAt),
      ),
    );
  }
  
  Future<void> updateTask(Task task) async {
    await (update(entities)..where((t) => t.id.equals(task.id))).write(
      EntitiesCompanion(
        title: Value(task.title),
        updatedAt: Value(task.updatedAt),
      ),
    );
    
    await (update(tasks)..where((t) => t.entityId.equals(task.id))).write(
      TasksCompanion(
        description: Value(task.description),
        status: Value(task.status.name),
        priority: Value(task.priority.name),
        dueDate: Value(task.dueDate),
        reminderAt: Value(task.reminderAt),
        timeEstimate: Value(task.timeEstimate),
        timeSpent: Value(task.timeSpent),
        completedAt: Value(task.completedAt),
      ),
    );
  }
  
  Future<void> deleteTask(String id) async {
    await (update(entities)..where((t) => t.id.equals(id))).write(
      EntitiesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
  
  Future<void> completeTask(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    await (update(entities)..where((t) => t.id.equals(id))).write(
      EntitiesCompanion(
        updatedAt: Value(now),
      ),
    );
    
    await (update(tasks)..where((t) => t.entityId.equals(id))).write(
      TasksCompanion(
        status: Value(TaskStatus.done.name),
        completedAt: Value(now),
      ),
    );
  }
  
  Task _mapToTask(TypedResult row) {
    final entity = row.readTable(entities);
    final taskData = row.readTable(tasks);
    
    return Task(
      id: entity.id,
      title: entity.title,
      description: taskData.description,
      status: TaskStatus.fromJson(taskData.status),
      priority: TaskPriority.fromJson(taskData.priority),
      dueDate: taskData.dueDate,
      reminderAt: taskData.reminderAt,
      completedAt: taskData.completedAt,
      timeEstimate: taskData.timeEstimate,
      timeSpent: taskData.timeSpent,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
