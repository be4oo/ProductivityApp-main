import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'companion/companion_app.dart';
import 'companion/companion_window.dart';
import 'companion/focus_session.dart';
import 'providers/persistent_project_provider.dart';
import 'providers/persistent_task_provider.dart';

/// Local-first desktop entry point. The existing API-backed entry stays intact.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final tasks = PersistentTaskProvider();
  final projects = PersistentProjectProvider();
  await tasks.initialize();
  await projects.initialize();
  await CompanionWindow.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tasks),
        ChangeNotifierProvider.value(value: projects),
        ChangeNotifierProvider(
          create: (_) => FocusSession(
            onMinutesLogged: (id, minutes) async {
              final task =
                  tasks.tasks.where((task) => task.id == id).firstOrNull;
              if (task != null) {
                await tasks.updateTask(
                  task.copyWith(actualTime: task.actualTime + minutes),
                );
              }
            },
          ),
        ),
        ChangeNotifierProvider(create: (_) => CompanionWindow()),
      ],
      child: const CompanionApp(),
    ),
  );
}
