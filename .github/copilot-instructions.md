# NahjulBalagha iOS App - AI Coding Instructions

## Project Overview
This is a SwiftUI-based iOS app for browsing and interacting with Nahj al-Balagha (Islamic literature). The app features AI-powered chat assistance, three main content sections (Sermons, Letters, Sayings), and a theming system.

## Architecture Patterns

### AI Integration Strategy
- **Primary AI Provider**: Apple's FoundationModels (on-device) via `#if canImport(FoundationModels)`
- **Fallback Provider**: OpenRouter API for cloud LLMs (requires API key in UserDefaults)
- **Local Stub**: Simple fallback for testing without network/AI
- **Key Files**: `AIChatService.swift` - handles provider switching and streaming responses
- **Pattern**: Uses `@Generable` structs with FoundationModels for structured AI outputs

### Theme & Color System
- **Central Theme File**: `Theme.swift` - defines `AppColors` struct with dynamic light/dark variants
- **Pattern**: All colors use `Color.dynamic(light:dark:)` for automatic theme switching
- **Usage**: Reference colors as `AppColors.background`, `AppColors.primary`, etc.
- **Storage**: Dark mode preference stored in UserDefaults with key "isDarkMode"

### Navigation Architecture
- **Root**: TabView with NavigationStack wrapping each tab (ContentView.swift)
- **Sections**: Home, Sermons, Letters, Sayings, Search, Settings
- **Modal Pattern**: Uses `.sheet(item:)` for detail views and AI-triggered navigation
- **Deep Linking**: AI can trigger section navigation via `AppSection` enum

### Data Models
- **SwiftData**: Uses `@Model` class `Item` (basic timestamp model for persistence)
- **View Models**: Simple structs (Sermon, Letter, Saying) with Identifiable protocol
- **Categories**: Enums for content categorization (SermonCategory, etc.)
- **Pattern**: Static data arrays with generated content for demonstration

## Development Workflow

### Build Configuration
- **Xcode Project**: `NahjulBalagha.xcodeproj` with schemes "NahjulBalagha" and "NahjulBalaghaProNext"
- **Target Platform**: iOS with iPhone 16 simulator testing
- **Dependencies**: SwiftUI, SwiftData, FoundationModels (conditional import)

### Testing Setup
- **Framework**: Swift Testing (not XCTest) - note `import Testing` in test files
- **Test Files**: `NahjulBalaghaTests.swift` uses `@Test` attribute and `#expect(...)` assertions
- **Pattern**: Write tests as functions with `@Test` attribute in struct

### Code Organization
```
NahjulBalagha/
├── NahjulBalaghaApp.swift     # Main app entry point, SwiftData setup
├── ContentView.swift          # Root TabView, AI chat integration
├── Theme.swift                # Centralized color/theme system
├── AIChatService.swift        # AI provider management, streaming
├── QuickOpenSection.swift     # App navigation enum
├── [Section]View.swift        # Individual content views (Sermons, Letters, etc.)
└── Item.swift                 # SwiftData model
```

## Key Conventions

### AI Chat Integration
- **Streaming Pattern**: Use `AsyncThrowingStream<PartialTurn, Error>` for AI responses
- **Tool Calls**: AI can trigger app navigation via structured responses
- **Provider Switching**: Check `availability` before using AI, graceful fallbacks
- **Session Management**: Use `makeToolEnabledSession()` to provide UI callbacks

### SwiftUI Patterns
- **Card Design**: Consistent rounded rectangles with `AppColors.card` background
- **List Styling**: Use `.listStyle(.plain)` with custom row backgrounds
- **Search**: Implement `.searchable()` with local filtering patterns
- **Category Chips**: Horizontal scrolling filter chips (see SermonCategoryChip)

### State Management
- **UserDefaults**: Used for AI provider, API keys, and theme preferences
- **@State**: Local view state for search, selections, modal presentation
- **@AppStorage**: For persistent settings like "isDarkMode"
- **@StateObject**: For AI service and other observables

## Critical Implementation Details

### AI Provider Conditional Compilation
```swift
#if canImport(FoundationModels)
// Apple Intelligence code
#else
// Fallback implementation
#endif
```

### Color Theme Usage
Always use `AppColors.*` constants, never hardcoded colors. Theme automatically adapts to system appearance.

### Modal Navigation Pattern
Use `.sheet(item: $binding)` with optional model types for AI-triggered navigation and detail views.

### Content Filtering
Implement search and category filtering in computed properties that filter base arrays using `localizedCaseInsensitiveContains()`.

## File Modification Guidelines
- **Theme Changes**: Modify only `Theme.swift` for color adjustments
- **AI Behavior**: Modify `AIChatService.swift` for provider logic, prompts in ContentView for chat behavior
- **New Content Types**: Follow Sermon pattern - create model struct, category enum, view with search/filter
- **Testing**: Use Swift Testing framework with `@Test` functions and `#expect()` assertions