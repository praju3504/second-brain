import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/app.dart';
import 'package:second_brain/presentation/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create provider container
  final container = ProviderContainer();
  
  // Initialize database
  await container.read(databaseProvider).init();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SecondBrainApp(),
    ),
  );
}
