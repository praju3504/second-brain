import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:second_brain/data/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
