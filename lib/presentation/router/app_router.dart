import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:second_brain/presentation/screens/files/files_screen.dart';
import 'package:second_brain/presentation/screens/home/home_screen.dart';
import 'package:second_brain/presentation/screens/notes/note_editor_screen.dart';
import 'package:second_brain/presentation/screens/notes/notes_list_screen.dart';
import 'package:second_brain/presentation/screens/settings/settings_screen.dart';
import 'package:second_brain/presentation/screens/tasks/task_detail_screen.dart';
import 'package:second_brain/presentation/screens/tasks/tasks_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/notes/new',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // Support for section anchors in the future: /notes/:id#section
          final uri = state.uri;
          final section = uri.fragment.isNotEmpty ? uri.fragment : null;
          
          return NoteEditorScreen(noteId: id);
        },
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TasksListScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskDetailScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/files',
        builder: (context, state) => const FilesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
