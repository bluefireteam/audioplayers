#!/usr/bin/env bash
# Runs `flutter test` with the given arguments and retries once when the test
# file fails to load before any test ran, e.g. when the Dart Development
# Service or the VM Service cannot be reached on the emulator.
#
# When FLUTTER_TEST_TIMEOUT is set (in seconds), an attempt that takes longer
# is stopped and retried as well, e.g. when the app never attaches to the test
# runner on the iOS simulator.
#
# When FLUTTER_TEST_BEFORE_RETRY is set, it is run before retrying, e.g. to
# restart an emulator that crashed.
set -o pipefail

timeout_seconds=${FLUTTER_TEST_TIMEOUT:-0}
log=$(mktemp)
for attempt in 1 2; do
  if [ "$attempt" -gt 1 ] && [ -n "$FLUTTER_TEST_BEFORE_RETRY" ]; then
    bash -c "$FLUTTER_TEST_BEFORE_RETRY"
  fi
  perl -e 'alarm shift; exec @ARGV' "$timeout_seconds" flutter test "$@" 2>&1 | tee "$log"
  code=$?
  if [ "$code" -eq 0 ]; then
    exit 0
  fi
  if [ "$code" -eq 142 ]; then
    echo "Test file timed out after ${timeout_seconds}s (attempt $attempt of 2)."
    continue
  fi
  if ! grep -q "Failed to load" "$log"; then
    exit "$code"
  fi
  echo "Test file failed to load (attempt $attempt of 2)."
done
exit "$code"
