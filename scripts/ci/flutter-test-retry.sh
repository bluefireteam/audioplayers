#!/usr/bin/env bash
# Runs `flutter test` with the given arguments and retries once when the test
# file fails to load before any test ran, e.g. when the Dart Development
# Service or the VM Service cannot be reached on the emulator.
set -o pipefail

log=$(mktemp)
for attempt in 1 2; do
  flutter test "$@" 2>&1 | tee "$log"
  code=$?
  if [ "$code" -eq 0 ]; then
    exit 0
  fi
  if ! grep -q "Failed to load" "$log"; then
    exit "$code"
  fi
  echo "Test file failed to load (attempt $attempt), retrying."
done
exit "$code"
