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

## Building & Running

```bash
# Open in Xcode
open NahjulBalagha.xcodeproj

# Build via command line
xcodebuild -project NahjulBalagha.xcodeproj -scheme NahjulBalagha -configuration Debug build

# Run on simulator
xcodebuild -project NahjulBalagha.xcodeproj -scheme NahjulBalagha \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
bundle exec fastlane ios test

# Deploy to TestFlight (requires setup - see DEPLOYMENT.md)
./build-and-upload.sh
# or
bundle exec fastlane ios beta
```

## Architecture

### Content Repository Pattern

**ContentRepository.swift** is the central data layer - a singleton (`ContentRepository.shared`) that:
- Holds all content as `@Published` arrays: `sermons`, `letters`, `sayings`
- Provides unified `search(_:)` method returning `[SearchResult]` enum
- Offers `getSermon(by:)`, `getLetter(by:)`, `getSaying(by:)` lookup methods
- Views observe it via `@ObservedObject private var repository = ContentRepository.shared`

**SearchResult.swift** defines an enum for type-safe search results:
```swift
enum SearchResult: Identifiable {
    case sermon(Sermon)
    case letter(Letter)
    case saying(Saying)
}
```

### Data Models

Models are defined in their respective view files:
- **SermonsView.swift**: `Sermon` struct + `SermonCategory` enum (wisdom/justice/leadership/faith/governance/morality)
- **LettersView.swift**: `Letter` struct + `LetterCategory` enum (governance/military/personal/instruction/advice/rebuke)
- **SayingsView.swift**: `Saying` struct + `SayingCategory` enum (wisdom/morality/faith/knowledge/justice/patience/character/worldly)

All models conform to `Identifiable` with UUID. Categories use `CaseIterable` for filter chips.

### Navigation Structure

**ContentView.swift** provides TabView with 6 tabs:
1. Home - AI chat assistant + quick navigation cards
2. Sermons - Categorized sermon list
3. Letters - Categorized letter list
4. Sayings - Wisdom aphorisms with favorites
5. Search - Global search via ContentRepository
6. Settings - Theme toggle and AI provider configuration

### AI Service Architecture

**AIChatService.swift** implements multi-provider AI with tool integration:

1. **Apple Intelligence**: Uses `@Generable` macro with `NBGeneratedTurn` struct for structured output. Requires `#if canImport(FoundationModels)` conditional compilation.

2. **OpenRouter**: REST API to `https://openrouter.ai/api/v1/chat/completions`. API key stored in UserDefaults under `openrouter_api_key`.

3. **Local Stub**: Pattern-matching fallback for testing.

**Tool actions**: `openSermons`, `openLetters`, `openSayings`, `setDarkMode` - executed via closures set in `makeToolEnabledSession()`.

### Theme System

**Theme.swift**: Dynamic light/dark palette using `Color.dynamic(light:dark:)`. All colors go through `AppColors` static properties. Uses HSL-based design with orange primary and teal secondary.

## Development Guidelines

### When Adding AI Features
- Wrap FoundationModels code in `#if canImport(FoundationModels)` blocks
- Use `@Generable` for structured output with Apple Intelligence
- Update `NBGeneratedTurn` struct if adding new tool capabilities
- Test with all three providers

### When Modifying UI
- Use `AppColors.*` constants instead of raw colors
- Maintain dark mode support via `Color.dynamic()`
- Keep consistent card styling (20pt corner radius, border, shadow)
- Use `.background(AppColors.background)` on navigation views

### Swift 6 Features
- Project uses Swift 6.0 with strict concurrency (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)
- Default actor isolation set to `@MainActor`
- Use `@MainActor` on view models and UI-updating classes

## Common Tasks

### To add a new content category
1. Update the relevant enum (SermonCategory, LetterCategory, etc.)
2. Add color mapping in `categoryColor(for:)` function
3. Filter chips auto-update (iterate over `allCases`)

### To add content items
Add to the `loadSermons()`, `loadLetters()`, or `loadSayings()` methods in `ContentRepository.swift`.

### To integrate markdown content from Content/ directory
Would require:
1. Bundle markdown files in Xcode project
2. Create markdown parser or use swift-markdown library
3. Replace hardcoded data in ContentRepository loaders with parsed content

## Known Limitations

- Content is hardcoded in ContentRepository, not loaded from markdown files
- No offline AI capability (requires network for OpenRouter, device support for Apple Intelligence)
- PeakofEloquence (macOS) target exists but may not be fully implemented
- No localization support
