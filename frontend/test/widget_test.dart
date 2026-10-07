import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:blitzit_flutter/companion/companion_window.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'package:blitzit_flutter/models/models.dart';

Task task(
  int id, {
  DateTime? due,
  String column = 'Backlog',
  TaskStatus status = TaskStatus.todo,
}) =>
    Task(
      id: id,
      title: 'Task $id',
      column: column,
      estimatedTime: 25,
      actualTime: 0,
      priority: TaskPriority.high,
      status: status,
      reminderEnabled: false,
      reminderOffset: 0,
      isUrgent: false,
      isImportant: false,
      projectId: 1,
      ownerId: 1,
      createdAt: DateTime(2026, 10, 7),
      updatedAt: DateTime(2026, 10, 7),
      dueDate: due,
    );
void main() {
  test('Latest window request wins while a resize is pending', () async {
    final firstResize = Completer<void>();
    final calls = <CompanionMode>[];
    final window = CompanionWindow(applyMode: (mode) async {
      calls.add(mode);
      if (calls.length == 1) await firstResize.future;
    });
    final opening = window.show(CompanionMode.planner);
    await window.show(CompanionMode.compact);
    firstResize.complete();
    await opening;
    expect(window.mode, CompanionMode.compact);
    expect(calls, [CompanionMode.planner, CompanionMode.compact]);
    expect(window.busy, false);
  });
  test('Window failure is recoverable and visible', () async {
    final window = CompanionWindow(applyMode: (_) async {
      throw StateError('Unavailable');
    });
    await window.show(CompanionMode.expanded);
    expect(window.mode, CompanionMode.compact);
    expect(window.busy, false);
    expect(window.error, isNotNull);
  });
  test('Focus logs whole minutes, carries fractions, and caps sleeping time',
      () async {
    var now = DateTime(2026, 10, 7);
    final logged = <int, int>{};
    final focus = FocusSession(
        now: () => now,
        onMinutesLogged: (id, minutes) async {
          logged[id] = (logged[id] ?? 0) + minutes;
        });
    addTearDown(focus.dispose);
    focus.select(task(1));
    focus.toggle();
    now = now.add(const Duration(seconds: 90));
    focus.toggle();
    await focus.flush();
    expect(logged[1], 1);
    focus.toggle();
    now = now.add(const Duration(seconds: 30));
    focus.toggle();
    await focus.flush();
    expect(logged[1], 2);
    focus.select(task(2));
    focus.toggle();
    now = now.add(const Duration(hours: 1));
    await focus.flush();
    expect(logged[2], 25);
  });
  test('Reopening a completed task clears its completion date explicitly', () {
    final completed = task(1)
        .copyWith(status: TaskStatus.completed, completedAt: DateTime(2026));
    expect(
        completed
            .copyWith(status: TaskStatus.todo, clearCompletedAt: true)
            .completedAt,
        isNull);
  });

  test('Focus uses wall time, pauses, resumes, and changes task safely', () {
    var now = DateTime(2026, 10, 7, 9);
    final focus = FocusSession(now: () => now);
    addTearDown(focus.dispose);
    focus.select(task(1));
    expect(focus.display, '25:00');
    focus.toggle();
    now = now.add(const Duration(minutes: 3, seconds: 10));
    expect(focus.display, '21:50');
    focus.toggle();
    now = now.add(const Duration(hours: 1));
    expect(focus.display, '21:50');
    focus.toggle();
    focus.select(task(1));
    expect(focus.display, '21:50');
    focus.select(task(2));
    expect(focus.isRunning, false);
    expect(focus.display, '25:00');
    focus.clear();
    expect(focus.taskId, null);
  });
  test('A sleeping device cannot leave a negative timer', () {
    var now = DateTime(2026, 10, 7);
    final focus = FocusSession(now: () => now);
    addTearDown(focus.dispose);
    focus.select(task(1));
    focus.toggle();
    now = now.add(const Duration(hours: 1));
    expect(focus.display, '00:00');
  });
  test(
    'Today excludes merely new, high priority, completed and future tasks',
    () {
      final day = DateTime(2026, 10, 7);
      expect(
        tasksForDay([
          task(1),
          task(2, due: day),
          task(3, due: day, status: TaskStatus.completed),
          task(4, due: day.add(const Duration(days: 1))),
          task(5, due: day, status: TaskStatus.done),
        ], day)
            .map((t) => t.id),
        [2],
      );
    },
  );
}
