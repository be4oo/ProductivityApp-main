import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// One session above both window presentations: resizing never restarts focus.
class FocusSession extends ChangeNotifier {
  FocusSession({DateTime Function()? now, this.onMinutesLogged})
      : _now = now ?? DateTime.now;
  final Future<void> Function(int taskId, int minutes)? onMinutesLogged;
  final Map<int, Duration> _unlogged = {};
  DateTime? _lastSample;
  Future<void> _writes = Future.value();
  String? loggingError;
  final Map<int, int> _failedMinutes = {};
  bool _disposed = false;
  final DateTime Function() _now;
  Timer? _ticker;
  DateTime? _deadline;
  Duration _remaining = const Duration(minutes: 25);
  int? taskId;
  bool get isRunning => _deadline != null;
  Duration get remaining {
    final value = _deadline?.difference(_now()) ?? _remaining;
    return value.isNegative ? Duration.zero : value;
  }

  String get display {
    final seconds = remaining.inMilliseconds <= 0
        ? 0
        : (remaining.inMilliseconds / 1000).ceil();
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void select(Task task) {
    if (taskId == task.id) return;
    _accountElapsed();
    _stop();
    taskId = task.id;
    _remaining = Duration(
      minutes: task.estimatedTime > 0 ? task.estimatedTime : 25,
    );
    notifyListeners();
  }

  void toggle() {
    if (taskId == null) return;
    if (isRunning) {
      _accountElapsed();
      _remaining = remaining;
      _stop();
    } else {
      if (_remaining == Duration.zero) _remaining = const Duration(minutes: 25);
      _lastSample = _now();
      _deadline = _lastSample!.add(_remaining);
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        _accountElapsed();
        if (remaining == Duration.zero) {
          _remaining = Duration.zero;
          _stop();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void clear() {
    _accountElapsed();
    _stop();
    taskId = null;
    _remaining = const Duration(minutes: 25);
    notifyListeners();
  }

  Future<void> flush() {
    _accountElapsed();
    return _writes;
  }

  void _accountElapsed() {
    if (_deadline == null || _lastSample == null || taskId == null) return;
    final now = _now();
    final end = now.isAfter(_deadline!) ? _deadline! : now;
    final elapsed = end.difference(_lastSample!);
    if (elapsed.isNegative) return;
    _lastSample = end;
    final id = taskId!;
    final total = (_unlogged[id] ?? Duration.zero) + elapsed;
    final minutes = total.inMinutes;
    _unlogged[id] = total - Duration(minutes: minutes);
    if (minutes > 0 && onMinutesLogged != null) {
      _enqueueMinutes(id, minutes);
    }
  }

  void _enqueueMinutes(int id, int minutes) {
    _writes = _writes.then((_) async {
      try {
        await onMinutesLogged!(id, minutes);
      } catch (_) {
        _failedMinutes[id] = (_failedMinutes[id] ?? 0) + minutes;
        loggingError = 'Focus time not saved. Retry in planner.';
        if (!_disposed) notifyListeners();
      }
    });
  }

  Future<void> retryLogging() async {
    await _writes;
    final pending = Map<int, int>.of(_failedMinutes);
    _failedMinutes.clear();
    loggingError = null;
    for (final entry in pending.entries) {
      _enqueueMinutes(entry.key, entry.value);
    }
    await _writes;
    if (!_disposed) notifyListeners();
  }

  void _stop() {
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
    _lastSample = null;
  }

  @override
  void dispose() {
    _accountElapsed();
    _stop();
    _disposed = true;
    super.dispose();
  }
}

bool isCompletedTask(Task task) =>
    task.status == TaskStatus.completed || task.status == TaskStatus.done;

bool isOpenTask(Task task) =>
    task.status != TaskStatus.completed &&
    task.status != TaskStatus.done &&
    task.status != TaskStatus.cancelled;

/// Today is an explicit column or calendar due date, never creation time/priority.
List<Task> tasksForDay(List<Task> tasks, DateTime day) => tasks.where((task) {
      if (!isOpenTask(task)) return false;
      final due = task.dueDate?.toLocal();
      final now = DateTime.now();
      final isToday =
          day.year == now.year && day.month == now.month && day.day == now.day;
      return (isToday && task.column.toLowerCase() == 'today') ||
          (due != null &&
              due.year == day.year &&
              due.month == day.month &&
              due.day == day.day);
    }).toList();
