#!/bin/sh
# Archives a signed Release build and uploads it to App Store Connect.
# Requirements: Xcode → Settings → Accounts signed in with the team's Apple ID,
# and an app record for bundle id com.tafinguyen.lichviet in App Store Connect.
# Each upload gets a unique build number (timestamp); the version comes from MARKETING_VERSION.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="$ROOT/build/LichViet-release.xcarchive"
BUILD_NUMBER="$(date +%Y%m%d%H%M)"

"$ROOT/Tests/run.sh"

xcodebuild -project "$ROOT/LichViet.xcodeproj" -scheme LichViet -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates CURRENT_PROJECT_VERSION="$BUILD_NUMBER" archive

xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$ROOT/AppStore/ExportOptions.plist" \
  -exportPath "$ROOT/build/export" -allowProvisioningUpdates

echo "Uploaded build $BUILD_NUMBER. It appears in App Store Connect → TestFlight after processing (~10–30 min)."
