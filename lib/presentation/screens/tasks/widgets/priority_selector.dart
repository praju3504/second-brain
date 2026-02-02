import 'package:flutter/material.dart';
import 'package:second_brain/core/theme/app_colors.dart';
import 'package:second_brain/domain/enums/task_priority.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final Function(TaskPriority) onPrioritySelected;
  
  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = selectedPriority == priority;
        final color = _getPriorityColor(priority);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => onPrioritySelected(priority),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? color : Colors.grey.shade300,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
              ),
              child: Text(priority.displayName),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.urgentPriority;
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }
}
