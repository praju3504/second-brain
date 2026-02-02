import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/core/constants/app_constants.dart';
import 'package:second_brain/core/extensions/date_extensions.dart';
import 'package:second_brain/core/theme/app_colors.dart';
import 'package:second_brain/presentation/providers/tasks_provider.dart';
import 'package:second_brain/presentation/widgets/empty_state.dart';

class UpcomingTasksWidget extends ConsumerWidget {
  const UpcomingTasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksNotifier = ref.read(tasksProvider.notifier);
    
    return FutureBuilder(
      future: tasksNotifier.getUpcomingTasks(AppConstants.upcomingTasksDays),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        
        final tasks = snapshot.data ?? [];
        
        if (tasks.isEmpty) {
          return const SizedBox(
            height: 200,
            child: EmptyState(
              icon: Icons.check_box_outlined,
              title: 'No upcoming tasks',
              subtitle: 'All clear for the week!',
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length.clamp(0, 5),
          itemBuilder: (context, index) {
            final task = tasks[index];
            final priorityColor = _getPriorityColor(task.priority.name);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 4,
                  color: priorityColor,
                ),
                title: Text(task.title),
                subtitle: task.dueDate != null
                    ? Text('Due: ${task.dueDate!.toDateTime().toFormattedDate()}')
                    : null,
                trailing: Icon(
                  Icons.circle,
                  size: 12,
                  color: priorityColor,
                ),
                onTap: () => context.push('/tasks/${task.id}'),
              ),
            );
          },
        );
      },
    );
  }
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.urgentPriority;
      case 'high':
        return AppColors.highPriority;
      case 'medium':
        return AppColors.mediumPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.lowPriority;
    }
  }
}
