import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/completion_celebration.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:blitzit_flutter/models/models.dart';
import 'widget_test.dart' as fixtures;

class CompletionTasks extends PersistentTaskProvider {
  final items = [
    fixtures.task(1, column: 'Today'),
    fixtures.task(2, column: 'Today')
  ];
  bool fail = false;
  int calls = 0;
  Completer<void>? pending;
  @override
  List<Task> get tasks => items;
  @override
  Future<void> toggleTaskCompletion(int id) async {
    calls++;
    if (pending != null) await pending!.future;
    if (fail) throw StateError('Storage unavailable');
    items.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}

Future<void> mount(WidgetTester tester, CompletionTasks tasks) async {
  final session = FocusSession();
  final window = CompanionWindow();
  addTearDown(session.dispose);
  await window.show(CompanionMode.expanded);
  await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<PersistentTaskProvider>.value(value: tasks),
        ChangeNotifierProvider<PersistentProjectProvider>.value(
            value: PersistentProjectProvider()),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: window),
      ],
      child: const RepaintBoundary(
        key: ValueKey('completion-preview'),
        child: CompanionApp(),
      )));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Bundled GIF decodes all 32 frames and contains a real animated dance',
      () async {
    final data = await rootBundle.load(CompletionCelebration.gifAsset);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    expect(String.fromCharCodes(bytes.take(6)), 'GIF89a');
    expect(bytes.length, lessThan(50000));
    final codec = await ui.instantiateImageCodec(bytes);
    addTearDown(codec.dispose);
    expect(codec.frameCount, 32);
    expect(codec.repetitionCount, -1);
    Uint8List? firstPixels;
    Uint8List? kickedPixels;
    for (var i = 0; i < codec.frameCount; i++) {
      final frame = await codec.getNextFrame();
      expect(frame.duration, const Duration(milliseconds: 80));
      expect(frame.image.width, 192);
      expect(frame.image.height, 128);
      if (i == 0 || i == 8) {
        final pixels = (await frame.image.toByteData())!.buffer.asUint8List();
        if (i == 0) firstPixels = pixels;
        if (i == 8) kickedPixels = pixels;
      }
      frame.image.dispose();
    }
    expect(kickedPixels, isNot(orderedEquals(firstPixels!)));
  });

  testWidgets(
      'Successful completions celebrate, allow clicks and restart cleanly',
      (tester) async {
    const previewPath = String.fromEnvironment('COMPLETION_PREVIEW_PATH');
    if (previewPath.isNotEmpty) {
      // Widget tests normally substitute Ahem boxes for fonts. Load the
      // bundled app fonts when producing a human-reviewable screenshot.
      await tester.runAsync(() async {
        await (FontLoader('Inter')
              ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
              ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf')))
            .load();
        await (FontLoader('MaterialIcons')
              ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
            .load();
      });
      debugDisableShadows = false;
    }
    final tasks = CompletionTasks();
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    expect(find.text('Task complete!'), findsOneWidget);
    final gifFinder = find.byKey(const ValueKey('completion-gif'));
    expect(gifFinder, findsOneWidget);
    final gif = tester.widget<Image>(gifFinder);
    expect(gif.image, const AssetImage(CompletionCelebration.gifAsset));
    final rawImage =
        find.descendant(of: gifFinder, matching: find.byType(RawImage));
    // GIF codecs decode off the test clock and publish frames on a scheduled
    // app frame. Keep pumping rather than awaiting precacheImage (which needs
    // that first frame), or pumpAndSettle (which loops while a GIF animates).
    for (var attempt = 0;
        attempt < 100 && tester.widget<RawImage>(rawImage).image == null;
        attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
    }
    expect(tester.widget<RawImage>(rawImage).image, isNotNull);
    // Opt-in screenshot for visual QA; ordinary test runs write no files.
    if (previewPath.isNotEmpty) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('completion-preview')));
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(previewPath).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      debugDisableShadows = true;
    }
    final firstCelebration = tester.element(find.byType(CompletionCelebration));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byTooltip('Complete Task 2'));
    await tester.pump();
    expect(tasks.calls, 2);
    expect(tester.element(find.byType(CompletionCelebration)),
        isNot(same(firstCelebration)));
    // The old timer must not dismiss the second celebration.
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.byType(CompletionCelebration), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed save stays visible, reports error and never celebrates',
      (tester) async {
    final tasks = CompletionTasks()..fail = true;
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Complete Task 1'), findsOneWidget);
    expect(find.byType(CompletionCelebration), findsNothing);
    expect(find.text('Task could not be saved. Please try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pending completion ignores repeated clicks and safely unmounts',
      (tester) async {
    final pending = Completer<void>();
    final tasks = CompletionTasks()..pending = pending;
    await mount(tester, tasks);
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    await tester.tap(find.byTooltip('Complete Task 1'));
    await tester.pump();
    expect(tasks.calls, 1);
    expect(find.byType(CompletionCelebration), findsNothing);
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Reduced motion uses a static success message and cancels on dispose',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var complete = 0;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: CompletionCelebration(onComplete: () => complete++),
    )));
    expect(find.text('Task complete!'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.bySemanticsLabel('Task completed. Great job!'), findsOneWidget);
    await tester.pump(CompletionCelebration.duration);
    expect(complete, 1);
    await tester.pumpWidget(
        MaterialApp(home: CompletionCelebration(onComplete: () => complete++)));
    expect(find.byKey(const ValueKey('completion-gif')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    expect(complete, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('Changing motion preference removes GIF without delaying done',
      (tester) async {
    var complete = 0;
    Widget subject(bool reduceMotion) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: CompletionCelebration(onComplete: () => complete++),
          ),
        );
    await tester.pumpWidget(subject(false));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpWidget(subject(true));
    expect(find.byType(Image), findsNothing);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(complete, 1);
    await tester.pump(const Duration(seconds: 3));
    expect(complete, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Compact companion keeps a static badge inside 420 by 84 pixels',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 420,
          height: 84,
          child: CompletionCelebration(onComplete: () {}),
        ),
      ),
    ));
    expect(find.byType(Image), findsNothing);
    expect(find.text('Task complete!'), findsOneWidget);
    final bounds = tester.getRect(find.byType(CompletionCelebration));
    final badge = tester.getRect(find.text('Task complete!'));
    expect(bounds.contains(badge.topLeft), isTrue);
    expect(bounds.contains(badge.bottomRight), isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Expanded GIF fits the 420px panel and never blocks a button',
      (tester) async {
    var clicks = 0;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 420,
          height: 540,
          child: Stack(fit: StackFit.expand, children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: TextButton(
                  onPressed: () => clicks++,
                  child: const Text('Keep working'),
                ),
              ),
            ),
            CompletionCelebration(onComplete: () {}),
          ]),
        ),
      ),
    ));
    final bounds = tester.getRect(find.byType(CompletionCelebration));
    final gif = tester.getRect(find.byKey(const ValueKey('completion-gif')));
    expect(bounds.contains(gif.topLeft), isTrue);
    expect(bounds.contains(gif.bottomRight), isTrue);
    await tester.tap(find.text('Keep working'));
    expect(clicks, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
