import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

enum CompanionMode { compact, expanded, planner }

class CompanionWindow extends ChangeNotifier {
  CompanionWindow({Future<void> Function(CompanionMode)? applyMode})
      : _applyMode = applyMode;
  final Future<void> Function(CompanionMode)? _applyMode;
  CompanionMode mode = CompanionMode.compact;
  bool busy = false;
  CompanionMode? _requested;
  String? error;
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static Future<void> initialize() async {
    if (!supported) return;
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(420, 84),
        backgroundColor: Colors.transparent,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
        title: 'Blitzit',
      ),
    );
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setAlignment(Alignment.topCenter);
    await windowManager.show();
  }

  Future<void> show(CompanionMode next) async {
    _requested = next;
    if (busy || next == mode) return;
    busy = true;
    notifyListeners();
    error = null;
    try {
      do {
        final target = _requested!;
        if (_applyMode != null) {
          await _applyMode!(target);
        } else if (supported) {
          final planner = target == CompanionMode.planner;
          await windowManager.setAlwaysOnTop(!planner);
          await windowManager.setResizable(planner);
          await windowManager.setMinimumSize(
            planner ? const Size(760, 600) : Size.zero,
          );
          await windowManager.setSize(
            planner
                ? const Size(1280, 820)
                : target == CompanionMode.expanded
                    ? const Size(420, 540)
                    : const Size(420, 84),
          );
          await windowManager.setAlignment(
            planner ? Alignment.center : Alignment.topCenter,
          );
          if (planner) await windowManager.focus();
        }
        mode = target;
        notifyListeners();
      } while (_requested != mode);
    } catch (_) {
      error = 'Window could not resize. Try again.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> drag() async {
    if (supported) await windowManager.startDragging();
  }
}
