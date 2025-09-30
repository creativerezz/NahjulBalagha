# TestFlight Deployment Guide

This guide covers deploying NahjulBalagha to TestFlight using either fastlane or xcodebuild commands.

## Quick Start

**Option 1: Using xcodebuild script (Recommended)**
```bash
# First time: Store password in keychain
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" \
  -u "your-apple-id@example.com" \
  -p "your-app-specific-password"

# Then deploy
./build-and-upload.sh
```

**Option 2: Using fastlane**
```bash
bundle install
bundle exec fastlane ios beta
```

See sections below for detailed setup.

## Prerequisites

1. **Apple Developer Account** with App Store distribution access
2. **App Store Connect** app created for NahjulBalagha
3. **Ruby** installed (macOS comes with Ruby pre-installed)
4. **Xcode** with valid signing certificates

## Initial Setup

### 1. Install Dependencies

```bash
# Install bundler if not already installed
gem install bundler

# Install fastlane and dependencies
bundle install
```

### 2. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your credentials
nano .env
```

Required variables:
- `FASTLANE_USER`: Your Apple ID email
- `FASTLANE_PASSWORD`: App-specific password (generate at appleid.apple.com)
- `FASTLANE_TEAM_ID`: Your team ID (default: G56KC8CS7Z)

### 3. Configure Code Signing

#### Option A: Automatic (Recommended)
In Xcode:
1. Open `NahjulBalagha.xcodeproj`
2. Select the project in the navigator
3. Select the "NahjulBalagha" target
4. Go to "Signing & Capabilities"
5. Enable "Automatically manage signing"
6. Select your team

#### Option B: Manual with fastlane match
```bash
# Initialize match (first time only)
bundle exec fastlane match init

# Get certificates and profiles
bundle exec fastlane match appstore
```

## Deployment Commands

### Deploy to TestFlight

```bash
# Full deployment (build + upload)
bundle exec fastlane ios beta
```

This will:
1. Increment build number automatically
2. Build the app for App Store distribution
3. Upload to TestFlight
4. Skip waiting for build processing (you'll get an email when ready)

### Build Only (No Upload)

```bash
bundle exec fastlane ios build_test
```

### Run Tests

```bash
bundle exec fastlane ios test
```

## Using xcodebuild (No Ruby Required)

### First Time Setup

1. **Store App Store Connect password in keychain:**
```bash
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" \
  -u "your-apple-id@example.com" \
  -p "your-app-specific-password"
```

Generate app-specific password at: https://appleid.apple.com

2. **Update build script:**
```bash
nano build-and-upload.sh
# Change APPLE_ID to your Apple ID email
```

### Deploy to TestFlight

```bash
./build-and-upload.sh
```

This script will:
1. Clean previous builds
2. Create archive
3. Export IPA for App Store
4. Upload to App Store Connect

### Manual xcodebuild Commands

See `XCODE_COMMANDS.md` for complete reference including:
- Building for simulator/device
- Running tests
- Creating archives
- Managing version/build numbers
- Code signing

## Manual Xcode Deployment

If you prefer using Xcode GUI:

1. Open `NahjulBalagha.xcodeproj` in Xcode
2. Select "Any iOS Device" or a connected device as the target
3. Product → Archive
4. In the Organizer, select the archive
5. Click "Distribute App"
6. Choose "App Store Connect"
7. Select "Upload"
8. Follow the prompts

## Versioning

- **Version Number**: Update manually in Xcode (Target → General → Version)
- **Build Number**: Auto-incremented by fastlane or manually in Xcode

Current version: 1.0 (see NahjulBalagha.xcodeproj)

## TestFlight Distribution

After upload to TestFlight:

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to your app → TestFlight
3. Wait for "Processing" to complete (~10-15 minutes)
4. Add internal testers or create external test groups
5. Submit for beta review if using external testing

## Troubleshooting

### "Could not find matching provisioning profile"
- Run `bundle exec fastlane match appstore` to sync profiles
- Or enable automatic signing in Xcode

### "Invalid code signature"
- Clean build folder: Xcode → Product → Clean Build Folder
- Verify certificate in Keychain Access
- Re-download provisioning profiles

### "Authentication failed"
- Verify `.env` file has correct credentials
- Generate new app-specific password at appleid.apple.com
- Enable two-factor authentication on Apple ID

## CI/CD Integration

For automated deployments with GitHub Actions, see `.github/workflows/` (to be added).

## Resources

- [fastlane Documentation](https://docs.fastlane.tools/)
- [App Store Connect Help](https://developer.apple.com/app-store-connect/)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)