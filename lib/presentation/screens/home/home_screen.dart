import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/presentation/screens/home/widgets/quick_actions_widget.dart';
import 'package:second_brain/presentation/screens/home/widgets/recent_notes_widget.dart';
import 'package:second_brain/presentation/screens/home/widgets/upcoming_tasks_widget.dart';
import 'package:second_brain/presentation/widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Brain'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const QuickActionsWidget(),
            const SizedBox(height: 32),
            Text(
              'Recent Notes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const RecentNotesWidget(),
            const SizedBox(height: 32),
            Text(
              'Upcoming Tasks',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const UpcomingTasksWidget(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/notes');
              break;
            case 2:
              context.go('/tasks');
              break;
            case 3:
              context.go('/files');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('New Note'),
              onTap: () {
                Navigator.pop(context);
                context.push('/notes/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box),
              title: const Text('New Task'),
              onTap: () {
                Navigator.pop(context);
                context.push('/tasks/new');
              },
            ),
          ],
        ),
      ),
    );
  }
}
