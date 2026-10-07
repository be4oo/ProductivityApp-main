import 'package:flutter_test/flutter_test.dart';
import 'package:blitzit_flutter/companion/local_task_commands.dart';
import 'package:blitzit_flutter/companion/focus_session.dart';
import 'widget_test.dart' as fixtures;

void main() {
  test('Local commands accept only the bounded start/finish vocabulary', () {
    expect(LocalTaskCommand.parse('start 12').action, LocalTaskAction.start);
    expect(LocalTaskCommand.parse('finish 42').taskId, 42);
    for (final input in [
      'https://host/finish/1',
      'start 0',
      'finish -1',
      'delete 1',
      'finish 1; rm -rf /',
      'start',
      'finish 1234567890'
    ]) {
      expect(() => LocalTaskCommand.parse(input), throwsFormatException);
    }
  });

  test('Failed focus minutes are retained and retry exactly once', () async {
    var now = DateTime(2026, 10, 7);
    var fail = true;
    var minutesSaved = 0;
    final session = FocusSession(
        now: () => now,
        onMinutesLogged: (_, minutes) async {
          if (fail) throw StateError('Disk unavailable');
          minutesSaved += minutes;
        });
    addTearDown(session.dispose);
    session.select(fixtures.task(1));
    session.toggle();
    now = now.add(const Duration(minutes: 3));
    session.toggle();
    await session.flush();
    expect(session.loggingError, isNotNull);
    expect(minutesSaved, 0);
    fail = false;
    await session.retryLogging();
    expect(minutesSaved, 3);
    expect(session.loggingError, isNull);
    await session.retryLogging();
    expect(minutesSaved, 3);
  });

  test(
      'Today column follows the actual day and completed/cancelled are excluded',
      () {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final tasks = [
      fixtures.task(1, column: 'Today'),
      fixtures.task(2, due: tomorrow)
    ];
    expect(tasksForDay(tasks, today).map((t) => t.id), [1]);
    expect(tasksForDay(tasks, tomorrow).map((t) => t.id), [2]);
  });
}
