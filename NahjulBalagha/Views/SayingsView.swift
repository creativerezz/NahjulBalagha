import SwiftUI

// MARK: - Data Models

struct Saying: Identifiable {
    let id = UUID()
    let number: Int
    let text: String
    let topic: String
    let explanation: String
    let category: SayingCategory
    let arabicText: String?
}

enum SayingCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case morality = "Morality"
    case faith = "Faith"
    case knowledge = "Knowledge"
    case justice = "Justice"
    case patience = "Patience"
    case character = "Character"
    case worldly = "Worldly Life"
}

// MARK: - Main View

struct SayingsView: View {
    @ObservedObject private var repository = ContentRepository.shared
    @State private var searchText = ""
    @State private var selectedCategory: SayingCategory? = nil
    @State private var selectedSaying: Saying? = nil
    @State private var favorites: Set<UUID> = []
    
    private var filteredSayings: [Saying] {
        var filtered = repository.sayings
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { saying in
                saying.text.localizedCaseInsensitiveContains(searchText) ||
                saying.topic.localizedCaseInsensitiveContains(searchText) ||
                saying.explanation.localizedCaseInsensitiveContains(searchText) ||
                saying.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                "Saying \(saying.number)".localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(SayingCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                .background(AppColors.background)
                
                // Sayings List
                if filteredSayings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("No sayings found")
                            .font(.headline)
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
                } else {
                    List(filteredSayings) { saying in
                        SayingRow(
                            saying: saying,
                            isFavorite: favorites.contains(saying.id),
                            toggleFavorite: {
                                withAnimation(.spring(response: 0.3)) {
                                    if favorites.contains(saying.id) {
                                        favorites.remove(saying.id)
                                    } else {
                                        favorites.insert(saying.id)
                                    }
                                }
                            },
                            action: {
                                selectedSaying = saying
                            }
                        )
                        .listRowBackground(AppColors.background)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search sayings...")
                }
            }
        }
        .navigationTitle("Sayings")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.background)
        .tint(AppColors.accent)
        .sheet(item: $selectedSaying) { saying in
            SayingDetailView(
                saying: saying,
                favorites: $favorites
            )
        }
    }
}

// MARK: - Saying Row

struct SayingRow: View {
    let saying: Saying
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saying \(saying.number)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.primary)
                        
                        Text(saying.topic)
                            .font(.headline)
                            .foregroundStyle(AppColors.cardForeground)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Favorite Button
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundStyle(isFavorite ? Color.red : AppColors.mutedForeground)
                        }
                        .buttonStyle(.plain)
                        
                        // Category Badge
                        Text(saying.category.rawValue)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(categoryColor(for: saying.category).opacity(0.15))
                            )
                            .foregroundStyle(categoryColor(for: saying.category))
                    }
                }
                
                // Main Quote
                Text("\"\(saying.text)\"")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(AppColors.foreground)
                    .italic()
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.muted)
                    )
                
                // Brief Explanation Preview
                if !saying.explanation.isEmpty {
                    Text(saying.explanation)
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryColor(for category: SayingCategory) -> Color {
        switch category {
        case .wisdom:
            return AppColors.primary
        case .morality:
            return AppColors.secondary
        case .faith:
            return AppColors.chart1
        case .knowledge:
            return AppColors.chart2
        case .justice:
            return AppColors.destructive
        case .patience:
            return AppColors.chart3
        case .character:
            return AppColors.chart4
        case .worldly:
            return AppColors.chart5
        }
    }
}

// MARK: - Saying Detail View

struct SayingDetailView: View {
    @State private var saying: Saying
    @Binding var favorites: Set<UUID>
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 18
    @State private var showArabic = false
    @ObservedObject private var repository = ContentRepository.shared

    init(saying: Saying, isFavorite: Bool, toggleFavorite: @escaping () -> Void) {
        // Legacy init for compatibility - converts to new binding style
        _saying = State(initialValue: saying)
        _favorites = .constant(isFavorite ? [saying.id] : [])
    }

    init(saying: Saying, favorites: Binding<Set<UUID>>) {
        _saying = State(initialValue: saying)
        _favorites = favorites
    }

    private var isFavorite: Bool {
        favorites.contains(saying.id)
    }

    private func toggleFavorite() {
        withAnimation(.spring(response: 0.3)) {
            if favorites.contains(saying.id) {
                favorites.remove(saying.id)
            } else {
                favorites.insert(saying.id)
            }
        }
    }

    private var currentIndex: Int? {
        repository.sayings.firstIndex(where: { $0.number == saying.number })
    }

    private var canGoNext: Bool {
        guard let index = currentIndex else { return false }
        return index < repository.sayings.count - 1
    }

    private var canGoPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    private func goToNext() {
        guard let index = currentIndex, canGoNext else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            saying = repository.sayings[index + 1]
            showArabic = false
        }
    }

    private func goToPrevious() {
        guard let index = currentIndex, canGoPrevious else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            saying = repository.sayings[index - 1]
            showArabic = false
        }
    }
    
    /// The rendered content of the SayingDetailView.
    /// 
    /// This property builds the full, scrollable detail experience for a single `Saying` inside a
    /// `NavigationStack`, using the app's color palette and typography.
    /// 
    /// Layout and behavior:
    /// - Displays a header with:
    ///   - The ordinal label (“Saying N”).
    ///   - A favorite toggle (heart icon) bound to `isFavorite` and `toggleFavorite`.
    ///   - A category badge tinted according to the saying's `SayingCategory`.
    ///   - The saying's topic as a prominent title.
    /// - Presents the main “The Saying” section:
    ///   - Shows either the English text or the Arabic text (if available), toggled by an “Arabic/English”
    ///     button. The Arabic variant is right-aligned and slightly larger for readability.
    ///   - Applies a serif font, italic styling for the English quote, and a soft, tinted background.
    ///   - Supports user-adjustable font size via the toolbar menu, bound to `fontSize`.
    /// - Optionally shows an “Explanation & Context” section when `explanation` is non-empty,
    ///   with comfortable line spacing for long-form reading.
    /// - Shows a “Related Topics” chip row derived from the saying’s category via `relatedTopics(for:)`.
    /// 
    /// Toolbar:
    /// - “Close” button that dismisses the sheet using the environment’s `dismiss`.
    /// - A Share action that exports a formatted quote (text-only) referencing the saying number.
    /// - A “Font Size” menu offering small/medium/large/extra-large presets with smooth animation.
    /// 
    /// Styling:
    /// - Uses `AppColors.background` as the base background and consistent foreground/accent colors
    ///   throughout the hierarchy.
    /// - Category tinting is provided by `categoryColor(for:)`.
    /// 
    /// Accessibility and interaction:
    /// - Button targets are sized and spaced for comfortable tapping.
    /// - Animated transitions when toggling Arabic/English and adjusting font size.
    /// 
    /// - SeeAlso: `categoryColor(for:)`, `relatedTopics(for:)`
    /// - Returns: A view hierarchy presenting detailed information and controls for the provided `saying`.
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Saying \(saying.number)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Favorite Button
                                Button(action: toggleFavorite) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 20))
                                        .foregroundStyle(isFavorite ? Color.red : AppColors.mutedForeground)
                                }
                                
                                // Category Badge
                                Text(saying.category.rawValue)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(categoryColor(for: saying.category).opacity(0.15))
                                    )
                                    .foregroundStyle(categoryColor(for: saying.category))
                            }
                        }
                        
                        Text(saying.topic)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.cardForeground)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: 24) {
                        // The Saying
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("The Saying")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppColors.cardForeground)
                                
                                if saying.arabicText != nil {
                                    Spacer()
                                    
                                    Button(action: { withAnimation { showArabic.toggle() } }) {
                                        Text(showArabic ? "English" : "Arabic")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .fill(AppColors.accent)
                                            )
                                            .foregroundStyle(AppColors.accentForeground)
                                    }
                                }
                            }
                            
                            if showArabic, let arabicText = saying.arabicText {
                                Text(arabicText)
                                    .font(.system(size: fontSize + 2, design: .serif))
                                    .foregroundStyle(AppColors.primary)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(AppColors.primary.opacity(0.05))
                                    )
                            } else {
                                Text("\"\(saying.text)\"")
                                    .font(.system(size: fontSize, weight: .medium, design: .serif))
                                    .foregroundStyle(AppColors.primary)
                                    .italic()
                                    .lineSpacing(4)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(AppColors.primary.opacity(0.05))
                                    )
                            }
                        }
                        
                        // Explanation
                        if !saying.explanation.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Explanation & Context")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppColors.cardForeground)
                                
                                Text(saying.explanation)
                                    .font(.system(size: fontSize - 2, design: .default))
                                    .foregroundStyle(AppColors.foreground)
                                    .lineSpacing(6)
                            }
                        }
                        
                        // Related Topics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Topics")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)

                            HStack {
                                ForEach(relatedTopics(for: saying), id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(AppColors.muted)
                                        )
                                        .foregroundStyle(AppColors.mutedForeground)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Navigation Hint
                    HStack {
                        if canGoPrevious {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedForeground)
                        }

                        Spacer()

                        if canGoNext {
                            HStack(spacing: 4) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedForeground)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background)
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height

                        if abs(horizontal) > abs(vertical) {
                            if horizontal < 0 && canGoNext {
                                goToNext()
                            } else if horizontal > 0 && canGoPrevious {
                                goToPrevious()
                            }
                        }
                    }
            )
            .navigationTitle("Saying \(saying.number)")
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppColors.accent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: "\"\(saying.text)\"\n\n- Saying \(saying.number) from Nahj al-Balagha") {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    Menu {
                        Section("Font Size") {
                            Button("Small") { withAnimation { fontSize = 16 } }
                            Button("Medium") { withAnimation { fontSize = 18 } }
                            Button("Large") { withAnimation { fontSize = 20 } }
                            Button("Extra Large") { withAnimation { fontSize = 22 } }
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
            }
        }
    }
    
    private func categoryColor(for category: SayingCategory) -> Color {
        switch category {
        case .wisdom:
            return AppColors.primary
        case .morality:
            return AppColors.secondary
        case .faith:
            return AppColors.chart1
        case .knowledge:
            return AppColors.chart2
        case .justice:
            return AppColors.destructive
        case .patience:
            return AppColors.chart3
        case .character:
            return AppColors.chart4
        case .worldly:
            return AppColors.chart5
        }
    }
    
    private func relatedTopics(for saying: Saying) -> [String] {
        var topics = [saying.category.rawValue]
        
        // Add related topics based on category
        switch saying.category {
        case .wisdom:
            topics.append(contentsOf: ["Philosophy", "Guidance"])
        case .morality:
            topics.append(contentsOf: ["Ethics", "Virtue"])
        case .faith:
            topics.append(contentsOf: ["Spirituality", "Devotion"])
        case .knowledge:
            topics.append(contentsOf: ["Learning", "Education"])
        case .justice:
            topics.append(contentsOf: ["Fairness", "Rights"])
        case .patience:
            topics.append(contentsOf: ["Perseverance", "Endurance"])
        case .character:
            topics.append(contentsOf: ["Personality", "Behavior"])
        case .worldly:
            topics.append(contentsOf: ["Life", "Material"])
        }
        
        return Array(topics.prefix(3))
    }
}

#Preview {
    NavigationStack {
        SayingsView()
            .background(AppColors.background)
    }
}

