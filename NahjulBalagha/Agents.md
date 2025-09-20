<write_file>
<path>AGENTS.md</path>
<content># Nahj al-Balagha AI Assistant Guide

## Project Overview

**Nahj al-Balagha** is a SwiftUI iOS application that serves as a digital library for Islamic texts, specifically focusing on the collected sermons, letters, and sayings of Imam Ali ibn Abi Talib. The app combines modern iOS development practices with AI-powered assistance to help users explore and search through this rich collection of wisdom literature.

### Core Purpose
- Provide easy access to Nahj al-Balagha texts (sermons, letters, sayings)
- Enable intelligent search and navigation through AI assistance
- Offer a beautiful, accessible reading experience with dark/light themes
- Support natural language queries for content discovery

### Technology Stack
- **Framework**: SwiftUI with SwiftData
- **AI Integration**: Apple Intelligence (Foundation Models) with local fallback
- **Architecture**: MVVM with structured components
- **Platform**: iOS 17+ (with iOS 26+ for AI features)

## Key Features

### 1. Tabbed Navigation
- **Home**: AI chat interface + quick access cards
- **Sermons**: Collection of Imam Ali's discourses
- **Letters**: Correspondence and guidance letters
- **Sayings**: Wise aphorisms and teachings
- **Search**: Content search functionality
- **Settings**: App configuration and preferences

### 2. AI-Powered Assistant
- Natural language understanding for content queries
- Direct actions: open sections, toggle themes
- Search result suggestions
- On-device processing with Apple Intelligence
- Graceful fallback when AI unavailable

### 3. Theming System
- Comprehensive dark/light mode support
- Dynamic color adaptation
- Accessible color palette
- Consistent visual hierarchy

## File Structure

```
NahjulBalagha/
├── NahjulBalaghaApp.swift      # App entry point & SwiftData setup
├── ContentView.swift          # Main tabbed interface
├── AIChatService.swift        # AI integration & chat logic
├── Theme.swift               # Color system & theming
├── Item.swift                # SwiftData model
├── SermonsView.swift         # Sermons section
├── LettersView.swift         # Letters section
├── SayingsView.swift         # Sayings section
├── SearchView.swift          # Search functionality
└── SettingsView.swift        # Settings & preferences
```

## Development Guidelines

### SwiftUI Best Practices
- Use declarative UI patterns
- Leverage SwiftUI's built-in state management
- Implement proper view composition
- Follow accessibility guidelines

### AI Integration
- Prefer on-device processing when available
- Provide meaningful fallback experiences
- Structure AI responses for UI consumption
- Handle errors gracefully

### Data Management
- Use SwiftData for persistence
- Implement proper data models
- Consider content loading strategies
- Plan for future content expansion

### Theming
- Use the established color system
- Support dynamic theme switching
- Maintain consistency across components
- Ensure accessibility compliance

## Common Tasks

### Adding New Content Types
1. Create new view following existing patterns
2. Add to tab navigation in ContentView
3. Update AI service to handle new section
4. Add appropriate data models

### Enhancing AI Features
1. Extend AIChatService with new capabilities
2. Update structured response types
3. Add new action handlers
4. Test fallback scenarios

### UI/UX Improvements
1. Follow established design patterns
2. Use AppColors consistently
3. Maintain responsive design
4. Test accessibility features

## Testing Considerations

- Test AI features with and without Apple Intelligence
- Verify theme switching functionality
- Ensure proper navigation flow
- Test search functionality
- Validate accessibility features

## Future Enhancements

- Content management system
- User bookmarks and annotations
- Advanced search filters
- Multi-language support
- Content sharing features
- Offline reading capabilities</content>
</write_file>