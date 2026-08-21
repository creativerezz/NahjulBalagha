# Xcode Command Line Reference

Complete reference for building, testing, and deploying NahjulBalagha using xcodebuild commands.

## Project Information

### List Schemes and Targets
```bash
xcodebuild -list -project NahjulBalagha.xcodeproj
```

### Show Build Settings
```bash
# All settings
xcodebuild -showBuildSettings -project NahjulBalagha.xcodeproj -scheme NahjulBalagha

# Specific configuration
xcodebuild -showBuildSettings -project NahjulBalagha.xcodeproj -scheme NahjulBalagha -configuration Release
```

## Building

### Build for Simulator (Development)
```bash
# Build for iPhone 16 simulator
xcodebuild \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build

# Build for generic iOS simulator
xcodebuild \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

### Build for Device (Requires Signing)
```bash
# Build for generic iOS device
xcodebuild \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  build
```

### Clean Build
```bash
xcodebuild clean \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha
```

## Testing

### Run Unit Tests
```bash
# Run all tests on iPhone 16 simulator
xcodebuild test \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:NahjulBalaghaTests

# Run specific test class
xcodebuild test \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:NahjulBalaghaTests/YourTestClass
```

### Run UI Tests
```bash
xcodebuild test \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:NahjulBalaghaUITests
```

## Archiving & Distribution

### Create Archive
```bash
xcodebuild archive \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -configuration Release \
  -archivePath ./build/NahjulBalagha.xcarchive \
  -destination 'generic/platform=iOS'
```

### Export Archive for App Store
```bash
# First, create exportOptions.plist (see below)
xcodebuild -exportArchive \
  -archivePath ./build/NahjulBalagha.xcarchive \
  -exportPath ./build/AppStore \
  -exportOptionsPlist exportOptions.plist
```

### Export Archive for Ad Hoc
```bash
xcodebuild -exportArchive \
  -archivePath ./build/NahjulBalagha.xcarchive \
  -exportPath ./build/AdHoc \
  -exportOptionsPlist exportOptions-adhoc.plist
```

## Simulator Management

### List Available Simulators
```bash
xcrun simctl list devices available
```

### Boot a Simulator
```bash
# Get device UUID from list above
xcrun simctl boot "iPhone 16"
```

### Install App on Simulator
```bash
# After building, get .app path from DerivedData
xcrun simctl install booted /path/to/NahjulBalagha.app
```

### Launch App on Simulator
```bash
xcrun simctl launch booted com.creativerez.NahjulBalagha
```

## Version & Build Number Management

### Get Current Version
```bash
agvtool what-marketing-version
```

### Get Current Build Number
```bash
agvtool what-version
```

### Set Version Number
```bash
agvtool new-marketing-version 1.1
```

### Increment Build Number
```bash
agvtool next-version -all
```

### Set Specific Build Number
```bash
agvtool new-version -all 42
```

## Code Signing

### List Available Certificates
```bash
security find-identity -v -p codesigning
```

### List Provisioning Profiles
```bash
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Show Provisioning Profile Details
```bash
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/YOUR_PROFILE.mobileprovision
```

## Export Options Plist

Create `exportOptions.plist` for App Store distribution:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>G56KC8CS7Z</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.creativerez.NahjulBalagha</key>
        <string>NahjulBalagha AppStore</string>
    </dict>
</dict>
</plist>
```

Create `exportOptions-adhoc.plist` for Ad Hoc distribution:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>G56KC8CS7Z</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

## Upload to App Store Connect

### Using xcodebuild (Xcode 13+)
```bash
# After exporting archive
xcrun altool --upload-app \
  --type ios \
  --file ./build/AppStore/NahjulBalagha.ipa \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD"
```

### Using xcrun (Newer Method)
```bash
xcrun altool --upload-package ./build/AppStore/NahjulBalagha.ipa \
  --type ios \
  --bundle-version 1.0 \
  --bundle-short-version-string 1.0 \
  --bundle-id com.creativerez.NahjulBalagha \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD"
```

### Store Password in Keychain
```bash
# Create keychain item for App Store Connect password
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" \
  -u "your-apple-id@example.com" \
  -p "your-app-specific-password"
```

## Complete Build & Upload Pipeline

```bash
#!/bin/bash
# build-and-upload.sh

set -e

PROJECT="NahjulBalagha.xcodeproj"
SCHEME="NahjulBalagha"
ARCHIVE_PATH="./build/NahjulBalagha.xcarchive"
EXPORT_PATH="./build/AppStore"

echo "🧹 Cleaning..."
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME"

echo "📦 Archiving..."
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -destination 'generic/platform=iOS'

echo "📤 Exporting..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist exportOptions.plist

echo "☁️  Uploading to App Store Connect..."
xcrun altool --upload-app \
  --type ios \
  --file "$EXPORT_PATH/NahjulBalagha.ipa" \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD"

echo "✅ Build uploaded successfully!"
```

Make it executable:
```bash
chmod +x build-and-upload.sh
./build-and-upload.sh
```

## Useful Shortcuts

### Quick Debug Build & Run on Simulator
```bash
xcodebuild \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build && \
  open -a Simulator && \
  xcrun simctl install booted $(find ~/Library/Developer/Xcode/DerivedData -name "NahjulBalagha.app" | head -1) && \
  xcrun simctl launch booted com.creativerez.NahjulBalagha
```

### Check for Compilation Errors Only
```bash
xcodebuild \
  -project NahjulBalagha.xcodeproj \
  -scheme NahjulBalagha \
  -destination 'generic/platform=iOS' \
  -dry-run
```

## Troubleshooting

### See Full Build Log
```bash
xcodebuild [...] | tee build.log
```

### Verbose Output
```bash
xcodebuild [...] -verbose
```

### Show SDK Path
```bash
xcrun --show-sdk-path --sdk iphoneos
```

### Show Xcode Path
```bash
xcode-select --print-path
```

## Resources

- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)