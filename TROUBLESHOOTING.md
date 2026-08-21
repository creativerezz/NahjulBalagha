# Troubleshooting TestFlight Deployment

## "No profiles matching" Error

**Error message:**
```
error: exportArchive No "iOS App Store" profiles for team 'Reza Jafar' matching 'NahjulBalagha AppStore' are installed.
```

**This means:** Xcode can't find the right provisioning profile for App Store distribution.

### Solution: Use Automatic Signing

✅ **Already fixed in this project** - Both `fastlane/Fastfile` and `exportOptions.plist` are now configured for automatic signing.

### Verify Xcode Settings

1. Open `NahjulBalagha.xcodeproj` in Xcode
2. Select the project in the navigator (blue icon)
3. Select the "NahjulBalagha" target
4. Go to "Signing & Capabilities" tab
5. **Make sure these are set:**
   - ✅ "Automatically manage signing" is **checked**
   - ✅ Team: "Reza Jafar (G56KC8CS7Z)"
   - ✅ Signing Certificate: "Apple Distribution"

6. Do the same for "Release" configuration (dropdown at top)

### Create App in App Store Connect

Before deploying, the app **must** exist in App Store Connect:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps"
3. Click the "+" button and select "New App"
4. Fill in:
   - **Platform:** iOS
   - **Name:** NahjulBalagha (or your preferred name)
   - **Primary Language:** English
   - **Bundle ID:** com.creativerez.NahjulBalagha
   - **SKU:** nahjulbalagha (or any unique identifier)
   - **User Access:** Full Access
5. Click "Create"

### Check Certificates

```bash
# List signing identities
security find-identity -v -p codesigning

# You should see:
# "Apple Distribution: Reza Jafar (G56KC8CS7Z)"
```

If you don't see "Apple Distribution", you need to:
1. Open Xcode → Settings → Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Click "+" and select "Apple Distribution"

### Manual Archive in Xcode (Recommended First Time)

To ensure everything is set up correctly, try a manual archive first:

1. Open `NahjulBalagha.xcodeproj` in Xcode
2. Select "Any iOS Device" (not simulator)
3. Product → Archive
4. Wait for archive to complete
5. In Organizer window, click "Distribute App"
6. Select "App Store Connect" → Next
7. Select "Upload" → Next
8. Let Xcode manage signing → Next
9. Review and upload

**If this works**, then the scripts will work too.

## Other Common Issues

### "App ID not found"

Create the App ID in Apple Developer Portal:
1. Go to [Developer Portal](https://developer.apple.com/account)
2. Certificates, Identifiers & Profiles → Identifiers
3. Click "+" to add new identifier
4. Select "App IDs" → Continue
5. Bundle ID: `com.creativerez.NahjulBalagha`
6. Enable any capabilities you need (App Groups, etc.)
7. Register

### "Authentication failed"

For fastlane:
1. Generate app-specific password at [appleid.apple.com](https://appleid.apple.com)
2. Update `.env` file with correct password
3. Make sure 2FA is enabled on Apple ID

For xcodebuild script:
```bash
# Store password in keychain
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" \
  -u "jafar.reza@icloud.com" \
  -p "your-app-specific-password"
```

### "Invalid version or build number"

Each TestFlight upload must have a unique build number:
```bash
# Increment build number
agvtool next-version -all

# Or set manually
agvtool new-version -all 3
```

### Clean Everything and Retry

```bash
# Clean Xcode build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/Archives/*

# Clean project
xcodebuild clean -project NahjulBalagha.xcodeproj -scheme NahjulBalagha

# Try again
bundle exec fastlane ios beta
```

## Deployment Checklist

- [ ] Apple Developer account active ($99/year)
- [ ] App created in App Store Connect
- [ ] App ID registered in Developer Portal
- [ ] Distribution certificate installed (Apple Distribution)
- [ ] "Automatically manage signing" enabled in Xcode
- [ ] Team ID correct (G56KC8CS7Z)
- [ ] Build number incremented (must be unique)
- [ ] App-specific password generated
- [ ] 2FA enabled on Apple ID

## Getting Help

If still stuck:
1. Check the full error log at `~/Library/Logs/gym/NahjulBalagha-NahjulBalagha.log`
2. Try manual archive in Xcode first
3. Verify all checklist items above
4. Check [fastlane troubleshooting](https://docs.fastlane.tools/codesigning/getting-started/)
5. Check [Apple's code signing guide](https://developer.apple.com/support/code-signing/)