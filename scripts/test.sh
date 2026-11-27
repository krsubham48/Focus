#!/bin/bash
# Core unit tests, then a quiet Simulator build.
set -euo pipefail
cd "$(dirname "$0")/.."
(cd FocusCore && swift test 2>&1 | tail -20)
xcodegen generate --quiet
xcodebuild -project Focus.xcodeproj -scheme Focus -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build build 2>&1 | xcbeautify --quieter
