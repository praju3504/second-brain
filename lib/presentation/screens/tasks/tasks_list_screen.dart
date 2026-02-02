import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/domain/enums/task_status.dart';
import 'package:second_brain/presentation/providers/tasks_provider.dart';
import 'package:second_brain/presentation/screens/tasks/widgets/task_card.dart';
import 'package:second_brain/presentation/widgets/app_bottom_nav.dart';
import 'package:second_brain/presentation/widgets/empty_state.dart';
import 'package:second_brain/presentation/widgets/loading_indicator.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  TaskStatus? _selectedStatus;
  
  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = null;
                    });
                    ref.read(tasksProvider.notifier).loadTasks();
                  },
                ),
                const SizedBox(width: 8),
                ...TaskStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.displayName),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                      if (selected) {
                        ref.read(tasksProvider.notifier).loadTasks(status: status);
                      } else {
                        ref.read(tasksProvider.notifier).loadTasks();
                      }
                    },
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: tasksState.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_box_outlined,
                    title: 'No tasks yet',
                    subtitle: 'Tap + to create your first task',
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: tasks[index],
                      onToggle: () {
                        ref.read(tasksProvider.notifier).toggleComplete(tasks[index].id);
                      },
                      onDelete: () {
                        ref.read(tasksProvider.notifier).deleteTask(tasks[index].id);
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/notes');
              break;
            case 2:
              break;
            case 3:
              context.go('/files');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
