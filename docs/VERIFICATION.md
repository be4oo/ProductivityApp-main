# Companion candidate verification

Base: `93177cb1b802209a86d2bf3deed512c36204d1c6`
Toolchain: official Flutter 3.32.8 / Dart 3.8.1, Linux cloud.

## Exercised

- Countdown wall-time behavior, pause/resume and switching tasks
- Whole-minute actual-time logging, fractional carry, sleep/deadline cap
- Latest-request-wins window controller and recoverable resize failure
- Compact → expanded → planner → compact → expanded → task completion
- Task editor open/close at the actual 420 × 540 companion size
- Rendering all three presentations with real bundled text/icon fonts
- Hive task/project reload, task completion/reopen and saved actual-time values
- Release web compilation of `lib/main_companion.dart`

The focused analyzer covers the companion, its entry point and tests. Full legacy
app analysis has no errors, but its existing broader lint backlog remains (28
warnings / 125 infos at the review checkpoint). The legacy auth/API entry point
is not being represented as production-ready.

## Evidence interpretation

PNG UI captures come directly from Flutter's running widget test renderer with
sample tasks. They are actual widget output, not a design mockup, but they do not
prove native macOS behavior. Browser preview was blocked by the cloud browser's
localhost policy; that restriction was not bypassed.

Native macOS compilation/package status must be read from the pull-request CI
run for the exact published commit. Linux cannot perform that build. No signing,
notarization, deployment, merge or user-computer access was performed.

Still to verify on macOS: top-edge placement and safe area, window dragging,
focus handoff, Spaces/full-screen behavior, repeated rapid resize/escape,
keyboard shortcuts and OS sleep/resume. Timer countdown is session-local and
resets after quitting; completed whole-minute actual time is saved to Hive.
