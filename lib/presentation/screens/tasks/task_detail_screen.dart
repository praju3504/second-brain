import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/domain/enums/task_priority.dart';
import 'package:second_brain/domain/enums/task_status.dart';
import 'package:second_brain/presentation/providers/tasks_provider.dart';
import 'package:second_brain/presentation/screens/tasks/widgets/priority_selector.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String? taskId;
  
  const TaskDetailScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  DateTime? _reminderAt;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTask();
  }
  
  Future<void> _loadTask() async {
    if (widget.taskId != null) {
      final repository = ref.read(taskRepositoryProvider);
      final task = await repository.getTaskById(widget.taskId!);
      if (task != null && mounted) {
        setState(() {
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _status = task.status;
          _priority = task.priority;
          _dueDate = task.dueDate != null 
              ? DateTime.fromMillisecondsSinceEpoch(task.dueDate! * 1000)
              : null;
          _reminderAt = task.reminderAt != null
              ? DateTime.fromMillisecondsSinceEpoch(task.reminderAt! * 1000)
              : null;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
          ),
          if (widget.taskId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PrioritySelector(
              selectedPriority: _priority,
              onPrioritySelected: (priority) {
                setState(() {
                  _priority = priority;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Due Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate == null 
                  ? 'No due date' 
                  : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications),
              title: Text(_reminderAt == null 
                  ? 'No reminder' 
                  : '${_reminderAt!.year}-${_reminderAt!.month.toString().padLeft(2, '0')}-${_reminderAt!.day.toString().padLeft(2, '0')} ${_reminderAt!.hour.toString().padLeft(2, '0')}:${_reminderAt!.minute.toString().padLeft(2, '0')}'),
              trailing: _reminderAt != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _reminderAt = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _reminderAt ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
                  );
                  if (time != null) {
                    setState(() {
                      _reminderAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    try {
      if (widget.taskId == null) {
        await ref.read(tasksProvider.notifier).addTask(
          title: title,
          description: _descriptionController.text.trim(),
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
          reminderAt: _reminderAt,
        );
      } else {
        final repository = ref.read(taskRepositoryProvider);
        final task = await repository.getTaskById(widget.taskId!);
        if (task != null) {
          final updatedTask = task.copyWith(
            title: title,
            description: _descriptionController.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: _dueDate?.millisecondsSinceEpoch ~/ 1000,
            reminderAt: _reminderAt?.millisecondsSinceEpoch ~/ 1000,
          );
          await ref.read(tasksProvider.notifier).updateTask(updatedTask);
        }
      }
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && widget.taskId != null) {
      await ref.read(tasksProvider.notifier).deleteTask(widget.taskId!);
      if (mounted) {
        context.pop();
      }
    }
  }
}
