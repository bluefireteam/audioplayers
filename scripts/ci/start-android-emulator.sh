#!/usr/bin/env bash
# Starts the "emu" AVD created by setup-android.sh and waits until it booted.
# Does nothing if an emulator is already connected, so it can also be used to
# bring back an emulator that crashed or disconnected.
#
# The output of the emulator and the warnings and errors of the device logcat
# are appended to files in ANDROID_LOG_DIR (default: $RUNNER_TEMP/android-logs),
# so they can be printed when the emulator crashed or disconnected.
set -e

adb="$ANDROID_HOME/platform-tools/adb"
log_dir=${ANDROID_LOG_DIR:-${RUNNER_TEMP:-/tmp}/android-logs}
mkdir -p "$log_dir"

if "$adb" devices | grep -q "^emulator-.*device$"; then
  echo "Emulator already running"
  exit 0
fi

echo "Starting emulator"
"$adb" kill-server || true
pkill -f qemu-system || true
echo "===== Starting emulator at $(date -u +%FT%TZ)" >> "$log_dir/emulator.log"
nohup "$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-snapshot -no-window >> "$log_dir/emulator.log" 2>&1 < /dev/null &
"$adb" wait-for-device shell "while [[ -z \$(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82"
echo "===== Emulator booted at $(date -u +%FT%TZ)" >> "$log_dir/logcat.log"
nohup "$adb" logcat -v threadtime "*:W" >> "$log_dir/logcat.log" 2>&1 < /dev/null &
"$adb" devices
echo "Emulator started"
