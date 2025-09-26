# NahjulBalagha iOS Repo · AI Guide
## Project Overview
This is a SwiftUI-based iOS app for browsing and interacting with Nahj al-Balagha (Islamic literature). The app features AI-powered chat assistance, three main content sections (Sermons, Letters, Sayings), and a theming system.

## Snapshot
- SwiftUI iOS app in `NahjulBalagha/` with entry point `NahjulBalaghaApp.swift` wiring SwiftData storage and showing `ContentView`.
- `ContentView.swift` hosts a six-tab `TabView` (Home, Sermons, Letters, Sayings, Search, Settings), each wrapped in its own `NavigationStack` to isolate navigation per tab.
- The Home tab embeds AI chat (via `AIChatService`) and quick links into the three primary content sections.

## Architecture Patterns
- `AIChatService.swift` switches between Apple Intelligence (`FoundationModels`), OpenRouter, and a local stub; availability gates every call, so observe `ai.availability` or `ai.isAvailable` before streaming.
- Streaming responses arrive as `AsyncThrowingStream<AssistantTurn.PartialTurn>`; keep placeholder chat rows until the stream completes, mirroring the `messages` handling in `ContentView`.
- AI tool calls surface through `AssistantTurn.Action`; call `makeToolEnabledSession` before streaming to wire navigation (`AppSection`) and dark-mode callbacks.
- OpenRouter integration hangs off `OpenRouterConfig`; UserDefaults keys: `ai_provider`, `selected_model`, `openrouter_api_key`, `isDarkMode`.

## UI & Styling
- Global colors live in `Theme.swift` as `AppColors` built with `Color.dynamic(light:dark:)`; never hardcode colors inside views.
- Card/list styling follows `SermonsView`, `LettersView`, and `SayingsView`: `.listStyle(.plain)`, `listRowBackground(AppColors.background)`, detail sheets via `.sheet(item:)`.
- Section chips reuse views like `SermonCategoryChip` and `CategoryChip`; keep their spacing, chip fills, and toggle logic when adding filters.

## Data & State
- Content sections use static arrays defined in each `[Section]View`; new sample items should match existing struct shapes (`Sermon`, `Letter`, `Saying`).
- SwiftData currently stores only `Item`; additional persistence should extend the schema in `NahjulBalaghaApp.swift`.
- Theme/AI preferences rely on the UserDefaults keys above—ensure settings UI and service logic stay in sync.

## AI Orchestration
- Home chat seeds `messages` with an assistant greeting and uses a placeholder UUID while streaming; follow this to keep scroll positions stable.
- `fallbackLocalHandling` covers offline navigation and theme toggles; update both the AI prompt strings and this method when adding commands.
- `SettingsView` drives provider/model selection: call `aiService.setProvider` / `setModel` and refresh availability so the status indicator stays accurate.

## Workflows
- Build/run locally with Xcode or from the CLI:
	```bash
	xcodebuild -scheme NahjulBalagha -destination "platform=iOS Simulator,name=iPhone 16" build
	```
- Tests use the Swift Testing package (`import Testing`); run them with
	```bash
	xcodebuild -scheme NahjulBalagha -destination "platform=iOS Simulator,name=iPhone 16" test
	```
	(`swift test` is not configured for this iOS target).
- Guard all FoundationModels code with Swift conditional compilation using `canImport(FoundationModels)` so Mac builds without the framework succeed.

## Extending the App
- To add a new content section, mirror `SermonsView.swift`: define a data model + category enum, provide chip filters, and present details via `.sheet(item:)`.
- Keep search UX local—filter in-memory arrays using `localizedCaseInsensitiveContains`, as done in the existing views.
- Adjust theming only in `Theme.swift`, then reuse `AppColors` tokens everywhere else; SwiftUI previews are already in place for quick verification.

## Implementation Guardrails
- When changing OpenRouter behavior, update both the system instructions string inside `streamWithOpenRouter` and the JSON parsing block that expects `reply`, `action`, and `searchResults` fields.
- Adding new `AppSection` cases requires updates to `QuickOpenSection.swift`, the Home quick links, and every AI action switch (FoundationModels, OpenRouter, and stub handlers).
- Extend sample data rather than replacing it; downstream views assume several entries for layout demonstrations.