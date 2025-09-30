# Content Directory

This directory contains all the source content for the Nahj al-Balagha app.

## Structure

- **Sermons/** - Contains 240+ markdown files for sermons (khutbah)
- **Letters/** - Contains 89+ markdown files for letters (correspondence)
- **Sayings/** - Contains markdown files for sayings and aphorisms
- **About/** - Background information about Nahj al-Balagha, Imam Ali, historical context, and study resources
- **Resources/** - Additional resources (PDFs, images, etc.)

## Integration Status

⚠️ **Note**: These markdown files are not currently integrated into the app. The app uses hardcoded sample data in the view files (`SermonsView.swift`, `LettersView.swift`, `SayingsView.swift`).

To integrate this content:
1. Add markdown parser (e.g., swift-markdown)
2. Bundle content files in Xcode project
3. Parse at runtime or build-time
4. Replace hardcoded data with parsed content