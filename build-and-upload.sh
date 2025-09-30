#!/bin/bash
# Build and Upload to TestFlight using xcodebuild
# Usage: ./build-and-upload.sh

set -e  # Exit on error

PROJECT="NahjulBalagha.xcodeproj"
SCHEME="NahjulBalagha"
ARCHIVE_PATH="./build/NahjulBalagha.xcarchive"
EXPORT_PATH="./build/AppStore"
APPLE_ID="jafar.reza@icloud.com"  # TODO: Update this

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 NahjulBalagha Build & Upload Script${NC}\n"

# Check if exportOptions.plist exists
if [ ! -f "exportOptions.plist" ]; then
    echo -e "${RED}❌ exportOptions.plist not found!${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf build/
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" -quiet

# Increment build number (optional - uncomment if using agvtool)
# echo -e "${BLUE}🔢 Incrementing build number...${NC}"
# agvtool next-version -all

# Archive
echo -e "${BLUE}📦 Creating archive...${NC}"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=G56KC8CS7Z

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Archive failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive created successfully${NC}"

# Export
echo -e "${BLUE}📤 Exporting archive...${NC}"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist exportOptions.plist \
  -quiet

if [ ! -f "$EXPORT_PATH/NahjulBalagha.ipa" ]; then
    echo -e "${RED}❌ Export failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IPA exported successfully${NC}"

# Get IPA size
IPA_SIZE=$(du -h "$EXPORT_PATH/NahjulBalagha.ipa" | cut -f1)
echo -e "${BLUE}📦 IPA Size: ${IPA_SIZE}${NC}"

# Upload to App Store Connect
echo -e "${BLUE}☁️  Uploading to App Store Connect...${NC}"
echo -e "${BLUE}(This may take several minutes)${NC}\n"

xcrun altool --upload-app \
  --type ios \
  --file "$EXPORT_PATH/NahjulBalagha.ipa" \
  --username "$APPLE_ID" \
  --password "@keychain:AC_PASSWORD"

echo -e "\n${GREEN}✅ Build uploaded successfully!${NC}"
echo -e "${BLUE}📱 Check App Store Connect in 10-15 minutes for build processing${NC}"
echo -e "${BLUE}🔗 https://appstoreconnect.apple.com${NC}"