#!/bin/bash
# Builds Focus and installs it on the connected iPhone.
# On a free Apple ID the app stops opening after 7 days: run this again.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f Config/Local.xcconfig ] || { echo "Missing Config/Local.xcconfig (add: DEVELOPMENT_TEAM = <your team ID>)"; exit 1; }
tmp=$(mktemp -d)
xcrun devicectl list devices --json-output "$tmp/devices.json" >/dev/null
udid=$(python3 -I - "$tmp/devices.json" <<'PY'
import json, sys
for d in json.load(open(sys.argv[1]))["result"]["devices"]:
    hardware = d.get("hardwareProperties", {})
    if (hardware.get("deviceType") == "iPhone"
            and hardware.get("reality") != "simulated"
            and d.get("connectionProperties", {}).get("tunnelState") != "unavailable"):
        print(hardware["udid"])
        break
PY
)
rm -rf "$tmp"
[ -n "$udid" ] || { echo "No iPhone connected. Plug it in, unlock it and try again."; exit 1; }
xcodegen generate --quiet
xcodebuild -project Focus.xcodeproj -scheme Focus -configuration Release -destination "id=$udid" \
  -derivedDataPath build -allowProvisioningUpdates -allowProvisioningDeviceRegistration build 2>&1 | xcbeautify --quieter
xcrun devicectl device install app --device "$udid" build/Build/Products/Release-iphoneos/Focus.app
xcrun devicectl device process launch --device "$udid" io.github.krsubham48.focus \
  || echo "Installed. Unlock the iPhone. On first install, trust the certificate in Settings > General > VPN & Device Management."
