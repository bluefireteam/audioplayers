#!/usr/bin/env bash
# Starts the "emu" AVD created by setup-android.sh and waits until it booted.
# Does nothing if an emulator is already connected, so it can also be used to
# bring back an emulator that crashed or disconnected.
set -e

adb="$ANDROID_HOME/platform-tools/adb"

if "$adb" devices | grep -q "^emulator-.*device$"; then
  echo "Emulator already running"
  exit 0
fi

echo "Starting emulator"
"$adb" kill-server || true
pkill -f qemu-system || true
nohup "$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-snapshot -no-window > /dev/null 2>&1 &
"$adb" wait-for-device shell "while [[ -z \$(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82"
"$adb" devices
echo "Emulator started"
