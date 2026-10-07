# Companion candidate verification

Toolchain: official Flutter 3.32.8 / Dart 3.8.1. Local checks run on Linux;
native build and launch checks run in the pull-request macOS workflow.

The final verification command is `flutter test` from `frontend`. The suite has
75 tests across nine files. Focused strict analysis covers the companion, its
entry point, both persistent providers, both editing dialogs, and all tests.
The release web build uses `lib/main_companion.dart`.

## Feature-to-test matrix

| Companion feature | Automated evidence |
|---|---|
| Window state and rapid switches | `widget_test.dart`: latest request wins, failed resize; `companion_widget_test.dart`: repeat compact/expanded/planner changes without resetting focus |
| Task create/edit, form validation, priority, description, tags, estimates | `feature_workflows_test.dart`: real editor saves into Hive, blank/cancel/repeated-submit cases, native-size 420×540 creation; `provider_crud_test.dart`: durable field preservation |
| Task delete/cancel/error | Both workflow and provider suites verify durable deletion, cancel preserving active focus, and failed writes preserving the task |
| Status, completion, history and reopening | Provider suite exercises all status/priority values and legacy `done`; workflow suite completes via check button and editor, filters history, reopens without losing fields |
| Project create/edit/delete/select, colors and reassignment | Provider and workflow suites exercise real CRUD, selected-project behavior, legacy named/hex colors, reassignment and orphan-task preservation |
| Due date/time and calendar days | Workflow suite drives both native Flutter pickers and day arrows; controller tests cover due-date filtering, actual Today column and exclusion rules |
| Focus countdown and minute accounting | `widget_test.dart`: wall-clock timing, pause/resume, switch, fractional carry, sleep/deadline cap; `companion_commands_test.dart`: retained failed minutes retry exactly once; workflow regressions preserve freshly flushed actual time on editor save and cancel |
| Storage/restart and existing installations | `persistence_test.dart` and 23 provider tests: real temp Hive reopen, completion timestamps, closed-box errors, startup failure, no reseeding of empty stores, legacy counter backfill and IDs never reused after deletion/restart |
| Actual offline GIF | Eight `completion_celebration_test.dart` cases decode all 32 frames, exercise actual `Image.asset` pixels, repeated completions, save failure, duplicate clicks, unmount, compact fit, reduced motion, and click-through interaction |
| Glass and accessibility | `glass_surface_test.dart`: blur/opaque rendering, saved preference, toggle persistence and high-contrast override; GIF suite verifies reduced-motion behavior |
| Keyboard and local commands | Workflow suite exercises ⌘P, Escape, ⌘K, start/finish, invalid/missing/closed IDs and failed completion; parser unit rejects arbitrary URLs/shell-like input |
| Render/layout | `companion_capture_test.dart` renders compact/expanded/planner with real bundled fonts; workflow tests cover 420×540, 760×600 and narrow planner layouts |

## Native evidence gate

The exact published commit must pass the macOS workflow's analyzer, full test
suite, native release build and packaging. The new launch smoke starts that
compiled app, waits for its first Flutter frame, confirms a visible NSWindow,
and requires the process to remain alive. It uses no screen-recording or
Accessibility permission. The job records `macos-runtime-smoke.log` alongside
the app zip and checksum.

A Linux UI capture is real Flutter widget output, not a design mockup, but it
cannot establish native desktop behavior. Manual Mac acceptance still needs
real wallpaper vibrancy, OS Reduce Transparency, dragging, top-edge safe area,
focus handoff, Spaces/full-screen behavior, keyboard behavior and OS sleep.
Native compile/launch does not replace those checks.

## Honest scope and persistence limits

The companion is local-first. Legacy authentication, backend sync, analytics,
import/export and separate legacy focus/break screens are not represented as
verified companion features. Their original source entry point remains.

Countdown/session state resets on quit; saved completed whole-minute actual
time and task/project data survive restart. Partial minutes carry between
sessions only while the app stays open. If a focus-time write fails, the retry
queue stays in memory: use **Retry saving focus time** before quitting.
The timer does not automatically complete a task or schedule an OS notification.

The downloadable app is an unsigned, unnotarized development candidate.
No user Mac, signing credentials, security settings, deployment or merge were
used for this verification. See `MACOS_CANDIDATE.md` and `LOCAL_TASK_COMMANDS.md`.
