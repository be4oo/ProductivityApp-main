# macOS companion candidate

Run `flutter run -d macos --target lib/main_companion.dart` or use the release app
produced by the macOS candidate workflow. The existing API-backed entry point
`lib/main.dart` is retained; this candidate launches the local-first companion.

## Included in the companion

- Compact always-on-top focus strip; expanded Today list; resizable planner
- Local task create/edit/delete, project reassignment, status and priority, tags,
  estimates, due date/time, completed history and reopen
- Project create/edit/delete and filtering; deleting a project retains its tasks
- Calendar-day navigation and all-task view
- Wall-clock focus timer, pause/resume, per-task minute accounting, save retry
- Original offline dancing-mascot GIF after a successful task completion
- macOS native vibrancy, readable tinted glass, saved solid-appearance option,
  system Reduce Transparency, high contrast and reduced-motion behavior
- Local task command palette (⌘K); ⌘P opens planner and Escape returns to compact

This is not a replacement for the separate backend-backed login, remote API
sync, analytics dashboard, settings, or legacy focus/break screens. Those source
features remain in the repository, but are not presented as verified companion
features. A timer by itself does not schedule an operating-system notification.

## Verification boundaries

The automated suite exercises models/controllers, real temporary Hive storage,
widget interaction flows and rendered captures. The macOS CI workflow builds the
native app and performs a bounded launch smoke: it waits for the first Flutter
frame, a visible native window and a live process. It does not request screen
recording or Accessibility permissions.

Manual testing of window dragging, Spaces/full-screen behavior, real wallpaper
vibrancy, macOS accessibility settings and hardware-specific graphics still
belongs in the final Mac acceptance check. A Linux Flutter render or a successful
compile does not prove those native interactions.

## Installation and signing

The CI download is an unsigned development candidate, not a notarized public
release. No signing identity, certificates, security settings, or Gatekeeper
configuration have been changed. macOS may require the user to approve opening
the downloaded app through its normal security flow. Do not disable Gatekeeper.
