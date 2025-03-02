#!/usr/bin/env
set -e

ANDROID_SDK_VERSION=${1:-35} # Default to 30 if no version is provided
ANDROID_SYSTEM_IMAGE_SOURCE=${2:-aosp_atd}
ANDROID_ABI=${3:-x86_64}

echo "Enable KVM permissions"
# see: https://github.com/actions/runner-images/discussions/7191
echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --name-match=kvm

echo "Setting up Android environment for API level $ANDROID_SDK_VERSION"

# Set environment variables
export ANDROID_AVD_HOME="$HOME/.android/avd"
echo "ANDROID_AVD_HOME=$ANDROID_AVD_HOME" >> "$GITHUB_ENV"
echo "ANDROID_AVD_HOME: $ANDROID_AVD_HOME"
mkdir -p "$ANDROID_AVD_HOME"

export ANDROID_CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools/latest/bin"
echo "ANDROID_CMDLINE_TOOLS=$ANDROID_CMDLINE_TOOLS" >> "$GITHUB_ENV"
echo "ANDROID_CMDLINE_TOOLS: $ANDROID_CMDLINE_TOOLS"

echo "Install Android Emulator"
"$ANDROID_CMDLINE_TOOLS"/sdkmanager --install "emulator"

AVD_IMAGE="system-images;android-$ANDROID_SDK_VERSION;$ANDROID_SYSTEM_IMAGE_SOURCE;$ANDROID_ABI"

echo "Install Android System Image: $AVD_IMAGE"
echo "y" | "$ANDROID_CMDLINE_TOOLS"/sdkmanager --install "$AVD_IMAGE"

echo "Create AVD with Image: $AVD_IMAGE"
echo "no" | "$ANDROID_CMDLINE_TOOLS"/avdmanager create avd --force --name emu --device "Nexus 5X" -k "$AVD_IMAGE"

echo "List available AVDs"
"$ANDROID_HOME"/emulator/emulator -list-avds

echo "Install platform tools"
"$ANDROID_CMDLINE_TOOLS"/sdkmanager "platform-tools"

# Start Emulator
echo "Starting emulator"
nohup "$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-snapshot -no-window &
"$ANDROID_HOME"/platform-tools/adb wait-for-device shell "while [[ -z \$(getprop sys.boot_completed | tr -d '\r') ]]; do sleep 1; done; input keyevent 82"
"$ANDROID_HOME"/platform-tools/adb devices
echo "Emulator started"
