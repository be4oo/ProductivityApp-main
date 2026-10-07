# Blitzit macOS companion candidate

This adds a local-first companion to the existing Flutter app. It reuses the
existing Task/Project models, Hive providers and editing dialogs. It does not
require FastAPI, an account, or any access to coding-assistant credentials.
The original `lib/main.dart` entry point remains available.

## Run

Use Flutter 3.32.8 and Xcode on macOS:

```sh
cd frontend
flutter pub get
flutter run -d macos --target lib/main_companion.dart
```

For browser UI verification (no native window behavior):

```sh
flutter run -d chrome --target lib/main_companion.dart
```

- Compact: current task, countdown, pause/resume, expand
- Expanded: Today tasks, focus, completion, add task, open planner
- Planner: all tasks, project selection/creation, previous/next day, task editing
- Return to compact with the top-right button or Escape; Command-P opens planner
- Drag the lightning icon to move the native window
- Compact/expanded modes are always-on-top; planner is a normal resizable window
- Task/project data stays in this app's existing local Hive boxes
- Timer state survives switching views; it is not restored after quitting
- Whole focus minutes are added to the task’s saved actual time; partial minutes
  carry between sessions until quitting (a final partial minute is not saved)
- The countdown uses a deadline so suspension/sleep does not extend a session
- Completing a timer does not automatically complete a task

Today means an explicit Today column or a matching due date, not a recently
created or high-priority task. New tasks default to the selected day.

## Candidate artifact

The pull-request workflow builds on a standard GitHub-hosted macOS runner and
uploads `Blitzit-macOS-candidate.zip` and a SHA-256 checksum. It does not deploy,
merge, publish a release, or use signing credentials. This is an unsigned /
not-notarized development candidate. Gatekeeper may require the owner to approve
opening it. Do not disable system security to run an untrusted download.

A passing build confirms compilation, not actual macOS window interaction.
Native smoke testing remains necessary: top-edge placement, drag, resizing,
Spaces/full-screen interactions, sleep/resume, repeated expand/collapse, and
keyboard focus. Browser screenshots cannot establish those behaviors.

## Reference

Interaction inspiration: https://github.com/vinzdg/codenotch (MIT license
reviewed). No CodeNotch code, assets, provider integration or credential-reading
logic is copied. This implementation is Flutter over the existing Blitzit data.

## Existing app issues

The legacy authentication UI is demo authentication, not account security.
The legacy backend has separate baseline issues; this candidate does not rely
on it. No production deployment or cloud synchronization is included.
