#!/usr/bin/env bash

function run_analyze() {
  result=$(flutter pub get 2>&1) # Sadly a pub get can block up our actions as it will retry forever if a package is not found, but this should atleast report everything else.
  if [ $? -ne 0 ]; then
    echo "flutter pub get failed:"
    echo "$result"
    exit 1
  fi

  result=$(flutter analyze .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "flutter analyze issue:"
    exit 1
  fi
}

echo "Starting Flame Analyzer"
echo "-----------------------"
for file in $(find . -type f -name "pubspec.yaml"); do
  dir=$(dirname $file)
  cd $dir
  echo "Analyzing $dir"
  run_analyze
  analyze_result=$?
  if [ $analyze_result -ne 0 ]; then
    exit $analyze_result
  fi
  cd $(cd -)
done

exit 0
