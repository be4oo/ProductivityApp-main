#!/bin/bash
# CI-only, bounded native launch check. No screen capture or accessibility grant.
set -euo pipefail
APP=${1:?Supply the built .app path}
EXEC=$(/usr/libexec/PlistBuddy -c 'Print CFBundleExecutable' "$APP/Contents/Info.plist")
LOG=${2:-macos-runtime-smoke.log}
BLITZIT_SMOKE_TEST=1 "$APP/Contents/MacOS/$EXEC" > "$LOG" 2>&1 &
PID=$!
trap 'kill "$PID" 2>/dev/null || true' EXIT
for attempt in $(seq 1 30); do
  if ! kill -0 "$PID" 2>/dev/null; then
    cat "$LOG"
    echo 'Native app exited before its first Flutter frame' >&2
    exit 1
  fi
  if grep -q 'BLITZIT_SMOKE_READY visible=true' "$LOG"; then
    sleep 3
    kill -0 "$PID"
    cat "$LOG"
    echo 'Native process stayed alive; visible window and first Flutter frame confirmed.'
    exit 0
  fi
  sleep 1
done
cat "$LOG"
echo 'No visible native-window first-frame signal within 30 seconds.' >&2
exit 1
