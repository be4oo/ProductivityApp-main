import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/models/models.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';

class PreviewTasks extends PersistentTaskProvider {
  @override
  List<Task> get tasks => List.generate(
      3,
      (i) => Task(
            id: i + 1,
            title: [
              'Review project requirements',
              'Sketch the next iteration',
              'Plan tomorrow’s priorities'
            ][i],
            column: 'Today',
            estimatedTime: [25, 50, 15][i],
            actualTime: 0,
            priority: TaskPriority.values[i],
            status: TaskStatus.todo,
            reminderEnabled: false,
            reminderOffset: 0,
            isUrgent: false,
            isImportant: true,
            projectId: 1,
            ownerId: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
}

class PreviewProjects extends PersistentProjectProvider {
  @override
  List<Project> get projects => [
        Project(
            id: 1,
            name: 'Personal workspace',
            color: 'green',
            ownerId: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now())
      ];
}

void main() {
  testWidgets('Render compact, expanded and planner from actual widgets',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await (FontLoader('Inter')
          ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    final session = FocusSession();
    final window = CompanionWindow();
    final tasks = PreviewTasks();
    session.select(tasks.tasks.first);
    final key = GlobalKey();
    for (final mode in CompanionMode.values) {
      tester.view.physicalSize = mode == CompanionMode.planner
          ? const Size(1280, 820)
          : mode == CompanionMode.expanded
              ? const Size(420, 540)
              : const Size(420, 84);
      await window.show(mode);
      await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: MultiProvider(providers: [
            ChangeNotifierProvider<PersistentTaskProvider>.value(value: tasks),
            ChangeNotifierProvider<PersistentProjectProvider>.value(
                value: PreviewProjects()),
            ChangeNotifierProvider.value(value: session),
            ChangeNotifierProvider.value(value: window),
          ], child: const CompanionApp())));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final directory = Platform.environment['COMPANION_SCREENSHOT_DIR'];
      if (directory != null) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(directory).create(recursive: true);
          await File('$directory/${mode.name}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    session.dispose();
  });
}
