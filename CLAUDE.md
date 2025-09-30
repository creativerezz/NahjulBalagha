# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**NahjulBalagha** is a SwiftUI iOS/iPadOS application (iOS 18+) that provides access to Nahj al-Balagha—the famous collection of sermons, letters, and sayings attributed to Imam Ali. The app includes:

- **Two build targets**:
  - `NahjulBalagha` (iOS/iPadOS app, main target)
  - `PeakofEloquence` (macOS app, secondary target)

- **AI-powered assistant** with multiple provider support:
  - Apple Intelligence (FoundationModels) - on-device AI using `@Generable` structured generation
  - OpenRouter - cloud LLM integration via REST API
  - Local stub fallback for testing

- **Content structure**: Sermons, Letters, and Sayings with categorization, search, and filtering

## Project Structure

```
NahjulBalagha/
├── NahjulBalagha/              # Main iOS app source
│   ├── NahjulBalaghaApp.swift  # App entry point
│   ├── ContentView.swift       # Main tab view
│   ├── AIChatService.swift     # Multi-provider AI service
│   ├── Theme.swift             # Color system
│   ├── SermonsView.swift       # Sermons tab
│   ├── LettersView.swift       # Letters tab
│   ├── SayingsView.swift       # Sayings tab
│   ├── SearchView.swift        # Search tab
│   ├── SettingsView.swift      # Settings tab
│   └── QuickOpenSection.swift  # Navigation enum
├── PeakofEloquence/            # macOS app source
├── NahjulBalaghaTests/         # Unit tests
├── NahjulBalaghaUITests/       # UI tests
├── Content/                    # Source content (not integrated)
│   ├── Sermons/               # 240+ sermon markdown files
│   ├── Letters/               # 89+ letter markdown files
│   ├── Sayings/               # Sayings markdown files
│   ├── About/                 # Background documentation
│   └── Resources/             # Additional resources
├── Icons/                      # App icons
├── fastlane/                   # Deployment automation
│   ├── Fastfile               # Deployment lanes
│   └── Appfile                # App configuration
├── NahjulBalagha.xcodeproj/   # Xcode project
├── CLAUDE.md                   # This file
├── DEPLOYMENT.md              # TestFlight deployment guide
├── Gemfile                    # Ruby dependencies
└── .gitignore                 # Git ignore rules
```

## Building & Running

### Development Build
```bash
# Open in Xcode
open NahjulBalagha.xcodeproj

# Build via command line
xcodebuild -project NahjulBalagha.xcodeproj -scheme NahjulBalagha -configuration Debug build
```

### Run on Simulator
```bash
# List available simulators
xcrun simctl list devices

# Build and run
xcodebuild -project NahjulBalagha.xcodeproj -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Deploy to TestFlight
```bash
# Install dependencies (first time only)
bundle install

# Deploy to TestFlight
bundle exec fastlane ios beta
```

See `DEPLOYMENT.md` for complete deployment instructions.

## Architecture

### App Entry Point
- **NahjulBalaghaApp.swift**: Main app entry with SwiftData ModelContainer setup
- Uses `Item` model for SwiftData persistence (currently placeholder)

### Navigation Structure
**ContentView.swift** provides TabView with 6 tabs:
1. Home - AI chat assistant + quick navigation cards
2. Sermons - Categorized by wisdom/justice/leadership/faith/governance/morality
3. Letters - Categorized by governance/military/personal/instruction/advice/rebuke
4. Sayings - Wisdom aphorisms
5. Search - Global search functionality
6. Settings - Theme toggle and AI provider configuration

### AI Service Architecture

**AIChatService.swift** implements multi-provider AI:

1. **Apple Intelligence (FoundationModels)**:
   - Uses `@Generable` macro with `NBGeneratedTurn` struct
   - Streams responses using `LanguageModelSession`
   - Requires `canImport(FoundationModels)` conditional compilation
   - Tool-calling via structured generation with actions (openSermons, setDarkMode, etc.)

2. **OpenRouter Integration**:
   - REST API calls to `https://openrouter.ai/api/v1/chat/completions`
   - API key stored in UserDefaults under `openrouter_api_key`
   - Supports multiple models (GPT-4, Claude, Llama, Gemini)
   - Parses JSON responses or falls back to text inference

3. **Local Stub**:
   - Pattern-matching fallback for testing without AI
   - Simulates delay and returns mock responses

**Tool Integration**:
- `makeToolEnabledSession()` sets up handlers for app navigation and theme switching
- Actions execute via closures: `openHandler`, `setDarkModeHandler`
- `streamTurn()` returns `AsyncThrowingStream<AssistantTurn.PartialTurn, Error>`

### Theme System

**Theme.swift**:
- Dynamic light/dark color palette using `Color.dynamic(light:dark:)`
- HSL-based design system with brand colors (orange primary, teal secondary)
- All colors go through `AppColors` static properties
- Uses UIColor hex initializer for precise color definitions

### View Components

**Sermons/Letters/Sayings Views**:
- List-based UI with category filters (horizontal scroll chips)
- Search integration via `.searchable` modifier
- Detail sheets with font size controls and share functionality
- Row components use custom card styling with borders and shadows

**QuickOpenSection.swift**: Enum for navigation between main sections

## Data Structure

### Current Implementation
- Hardcoded sample data in view files
- `Sermon`, `Letter` models are structs with categories
- SwiftData ModelContainer exists but uses placeholder `Item` model

### Content Directory (Not Yet Integrated)
`Content/` contains markdown files organized by:
- `Sermons/` - 240+ markdown files for sermons (khutbah)
- `Letters/` - 89+ markdown files for letters (correspondence)
- `Sayings/` - Markdown files for sayings and aphorisms
- `About/` - Background information (historical context, authenticity, study resources)
- `Resources/` - Additional resources (PDFs, images, etc.)

See `Content/README.md` for more details.

**Note**: These markdown files are NOT currently parsed or loaded by the app. Content is hardcoded in view files.

## Development Guidelines

### When Adding AI Features
- Wrap FoundationModels code in `#if canImport(FoundationModels)` blocks
- Use `@Generable` for structured output with Apple Intelligence
- Update `NBGeneratedTurn` struct if adding new tool capabilities
- Test with all three providers (Apple Intelligence, OpenRouter, Local Stub)

### When Modifying UI
- Use `AppColors.*` constants instead of raw colors
- Maintain dark mode support via `Color.dynamic()`
- Keep consistent card styling (20pt corner radius, border, shadow)
- Use `.background(AppColors.background)` on navigation views

### When Working with Content Models
- Models are defined locally in each view file (not centralized)
- Categories use enums with `CaseIterable` for filter chips
- All content models conform to `Identifiable` with UUID

### Swift 6 Features
- Project uses Swift 6.0 with strict concurrency (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)
- Default actor isolation set to `@MainActor`
- Use `@MainActor` on view models and UI-updating classes

## Common Tasks

### Deploy to TestFlight

**Using xcodebuild (no Ruby required):**
```bash
./build-and-upload.sh
```

**Using fastlane:**
```bash
bundle exec fastlane ios beta
```

**Using Xcode:**
- Product → Archive → Distribute App → App Store Connect

See `DEPLOYMENT.md` for setup and `XCODE_COMMANDS.md` for complete xcodebuild reference.

### To change AI provider
User changes it in SettingsView, which calls `AIChatService.setProvider(_:)`

### To add a new content category
1. Update the relevant enum (SermonCategory, LetterCategory, etc.)
2. Add color mapping in `categoryColor(for:)` function
3. Update filter chips UI (already iterates over `allCases`)

### To integrate markdown content
Would require:
1. Bundle markdown files in Xcode project (add `Content/` to target)
2. Create markdown parser or use library (e.g., swift-markdown)
3. Replace hardcoded data in views with parsed content
4. Consider caching strategy with SwiftData

## Known Limitations

- Content is currently hardcoded, not loaded from markdown files
- SwiftData Item model is placeholder, not used
- No offline AI capability (requires network for OpenRouter, device support for Apple Intelligence)
- PeakofEloquence (macOS) target exists but may not be fully implemented
- No localization support yet