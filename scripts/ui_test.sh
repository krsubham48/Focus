#!/bin/bash
# UI tests. Screenshots are kept in build/ui.xcresult.
set -euo pipefail
cd "$(dirname "$0")/.."
xcodegen generate --quiet
xcrun simctl bootstatus 'iPhone 17' -b >/dev/null
rm -rf build/ui.xcresult
xcodebuild -project Focus.xcodeproj -scheme Focus -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build -resultBundlePath build/ui.xcresult -parallel-testing-enabled NO \
  ${1:+-only-testing:FocusUITests/FlowUITests/$1} test 2>&1 | xcbeautify --quieter
