import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blitzit_flutter/companion/companion_app.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/providers/persistent_task_provider.dart';
import 'package:blitzit_flutter/providers/persistent_project_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blitzit_flutter/companion/glass_surface.dart';

void main() {
  testWidgets(
      'Saved solid preference is applied, toggle persists, high contrast stays opaque',
      (tester) async {
    SharedPreferences.setMockInitialValues({'companion.opaque': true});
    final window = CompanionWindow();
    final session = FocusSession();
    await window.show(CompanionMode.planner);
    tester.view.physicalSize = const Size(1000, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<PersistentTaskProvider>.value(
          value: PersistentTaskProvider()),
      ChangeNotifierProvider<PersistentProjectProvider>.value(
          value: PersistentProjectProvider()),
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider.value(value: window),
    ], child: const CompanionApp()));
    await tester.pumpAndSettle();
    expect(
        tester.widget<GlassSurface>(find.byType(GlassSurface)).opaque, isTrue);
    await tester.ensureVisible(find.text('Glass / solid appearance'));
    await tester.tap(find.text('Glass / solid appearance'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<GlassSurface>(find.byType(GlassSurface)).opaque, isFalse);
    expect((await SharedPreferences.getInstance()).getBool('companion.opaque'),
        isFalse);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    await tester.pumpAndSettle();
    expect(
        tester.widget<GlassSurface>(find.byType(GlassSurface)).opaque, isTrue);
    await tester.pumpWidget(const SizedBox());
    session.dispose();
    window.dispose();
  });
  testWidgets(
      'Glass uses blur; solid accessibility mode removes it without hiding content',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: GlassSurface(opaque: false, child: Text('Readable task'))));
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('Readable task'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(
        home: GlassSurface(opaque: true, child: Text('Readable task'))));
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Readable task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
