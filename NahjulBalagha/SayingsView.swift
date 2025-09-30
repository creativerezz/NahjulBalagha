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
    @State private var searchText = ""
    @State private var selectedCategory: SayingCategory? = nil
    @State private var selectedSaying: Saying? = nil
    @State private var favorites: Set<UUID> = []
    
    private let sayings: [Saying] = sampleSayings
    
    private var filteredSayings: [Saying] {
        var filtered = sayings
        
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
                isFavorite: favorites.contains(saying.id),
                toggleFavorite: {
                    withAnimation {
                        if favorites.contains(saying.id) {
                            favorites.remove(saying.id)
                        } else {
                            favorites.insert(saying.id)
                        }
                    }
                }
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
    let saying: Saying
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 18
    @State private var showArabic = false
    
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
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Saying Details")
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

// MARK: - Sample Data

private let sampleSayings: [Saying] = [
    Saying(
        number: 1,
        text: "During civil disturbance be like an adolescent camel who has neither a back strong enough for riding nor udders for milking.",
        topic: "On remaining neutral in conflicts",
        explanation: "This saying advises neutrality during times of civil unrest. Just as a young camel is not yet useful for riding or milking, one should not be of use to either side in a conflict that divides the community. This promotes peace and prevents fueling division.",
        category: .wisdom,
        arabicText: "كُنْ فِي الْفِتْنَةِ كَابْنِ اللَّبُونِ لَا ظَهْرٌ فَيُرْكَبَ وَلَا ضَرْعٌ فَيُحْلَبَ"
    ),
    Saying(
        number: 2,
        text: "He who adopts greed as a habit devalues himself; he who discloses his hardship agrees to humiliation; and he who allows his tongue to overpower his soul debases the soul.",
        topic: "On greed, complaints, and speech",
        explanation: "This profound saying warns against three character flaws: greed diminishes one's dignity, constantly complaining about difficulties invites humiliation, and letting the tongue speak without restraint degrades one's spiritual essence.",
        category: .character,
        arabicText: nil
    ),
    Saying(
        number: 3,
        text: "Miserliness is the companion of poverty; cowardice is the companion of destitution; and poverty often deprives an intelligent man of his argument.",
        topic: "On poverty and its effects",
        explanation: "This saying explores the relationship between material and spiritual poverty. Miserliness leads to poverty of spirit, cowardice to moral bankruptcy, and material poverty can prevent even the wisest from being heard.",
        category: .worldly,
        arabicText: nil
    ),
    Saying(
        number: 4,
        text: "One who fights for a cause not his own is not intelligent.",
        topic: "On choosing battles wisely",
        explanation: "This teaches discernment in conflict. Fighting for causes that don't align with one's principles or that don't genuinely concern one's welfare or values demonstrates a lack of wisdom.",
        category: .wisdom,
        arabicText: nil
    ),
    Saying(
        number: 5,
        text: "Knowledge is better than wealth. Knowledge guards you, while you have to guard wealth. Wealth decreases by spending, while knowledge multiplies by spending.",
        topic: "The superiority of knowledge over wealth",
        explanation: "This famous saying establishes the supremacy of knowledge over material wealth. Knowledge protects its possessor from ignorance and error, while wealth requires constant protection. When shared, knowledge grows while wealth diminishes.",
        category: .knowledge,
        arabicText: "الْعِلْمُ خَيْرٌ مِنَ الْمَالِ، الْعِلْمُ يَحْرُسُكَ وَأَنْتَ تَحْرُسُ الْمَالَ"
    ),
    Saying(
        number: 6,
        text: "Patience is of two kinds: patience over what pains you, and patience against what you covet.",
        topic: "The two types of patience",
        explanation: "This distinguishes between enduring hardship (patience in adversity) and resisting temptation (patience in prosperity). Both forms of patience are essential for spiritual development.",
        category: .patience,
        arabicText: "الصَّبْرُ صَبْرَانِ: صَبْرٌ عَلَى مَا تَكْرَهُ، وَصَبْرٌ عَمَّا تُحِبُّ"
    ),
    Saying(
        number: 7,
        text: "The tongue is a beast; if it is let loose, it devours.",
        topic: "On controlling speech",
        explanation: "This metaphor warns about the destructive power of uncontrolled speech. Like a wild beast, the tongue can cause immense harm if not properly restrained through wisdom and self-control.",
        category: .morality,
        arabicText: nil
    ),
    Saying(
        number: 8,
        text: "Woman is a scorpion whose grip is sweet.",
        topic: "On temptation and desire",
        explanation: "This metaphorical saying warns about the dual nature of temptation - it may seem pleasant initially but can lead to harmful consequences if one is not careful and mindful.",
        category: .worldly,
        arabicText: nil
    ),
    Saying(
        number: 9,
        text: "If you are greeted, return the greetings more warmly. If you are favored, return the favor manifold; but he who takes the initiative will always excel in merit.",
        topic: "On reciprocating goodness",
        explanation: "This teaches the ethics of social interaction: respond to kindness with greater kindness, but recognize that initiating good deeds holds the highest merit.",
        category: .morality,
        arabicText: nil
    ),
    Saying(
        number: 10,
        text: "The worth of every man is in his attainments.",
        topic: "On human worth and achievement",
        explanation: "This saying emphasizes that a person's true value lies not in lineage, wealth, or status, but in what they have learned, accomplished, and contributed to society.",
        category: .knowledge,
        arabicText: "قِيمَةُ كُلِّ امْرِئٍ مَا يُحْسِنُهُ"
    ),
    Saying(
        number: 11,
        text: "I wonder at the man who loses hope of salvation when the door of repentance is open for him.",
        topic: "On hope and repentance",
        explanation: "This expresses amazement at those who despair when God's mercy is always available through sincere repentance. It encourages maintaining hope even after mistakes.",
        category: .faith,
        arabicText: nil
    ),
    Saying(
        number: 12,
        text: "Generosity is that which is by one's own initiative, because giving on request is either out of self-respect or to avoid rebuke.",
        topic: "True generosity",
        explanation: "Real generosity comes from the heart without being asked. When one gives only upon request, it may be motivated by shame or fear of criticism rather than genuine kindness.",
        category: .character,
        arabicText: nil
    ),
    Saying(
        number: 13,
        text: "There is no wealth like wisdom, no destitution like ignorance, no inheritance like refinement, and no support like consultation.",
        topic: "Four invaluable treasures",
        explanation: "This saying identifies four invaluable assets: wisdom as the greatest wealth, ignorance as the worst poverty, good character as the best inheritance, and consultation as the strongest support.",
        category: .wisdom,
        arabicText: nil
    ),
    Saying(
        number: 14,
        text: "Patience is of two kinds: patience over what pains you, and patience against what you covet.",
        topic: "On types of patience",
        explanation: "This distinguishes between enduring hardship (patience in adversity) and resisting temptation (patience against desires). Both require strength and self-control.",
        category: .patience,
        arabicText: nil
    ),
    Saying(
        number: 15,
        text: "Wealth converts a strange land into homeland and poverty turns a native place into a strange land.",
        topic: "The effect of wealth and poverty",
        explanation: "This observation on human nature shows how material conditions affect one's sense of belonging. Wealth can make one feel at home anywhere, while poverty can alienate one from their birthplace.",
        category: .worldly,
        arabicText: nil
    ),
    Saying(
        number: 16,
        text: "Contentment is the capital which will never diminish.",
        topic: "The value of contentment",
        explanation: "Contentment with what one has is described as an inexhaustible treasure. Unlike material wealth, satisfaction and gratitude provide lasting richness that cannot be depleted.",
        category: .character,
        arabicText: "الْقَنَاعَةُ مَالٌ لَا يَنْفَدُ"
    ),
    Saying(
        number: 17,
        text: "Every breath you take is a step towards death.",
        topic: "On mortality and time",
        explanation: "This stark reminder of mortality encourages mindfulness about the finite nature of life. Each moment brings us closer to our end, making every breath precious.",
        category: .wisdom,
        arabicText: nil
    ),
    Saying(
        number: 18,
        text: "The sin which makes you sad and repentant is more liked by Allah than the good deed which turns you arrogant.",
        topic: "Humility versus arrogance",
        explanation: "This profound spiritual insight shows that sincere repentance after sin is better than acts of worship that lead to pride. Humility is more valuable than corrupted virtue.",
        category: .faith,
        arabicText: nil
    ),
    Saying(
        number: 19,
        text: "The value of a man is according to his courage, his truthfulness is according to his balance of temper, his valour is according to his self-respect, and his chastity is according to his sense of shame.",
        topic: "Measures of character",
        explanation: "This saying provides metrics for evaluating character: courage determines worth, emotional balance indicates honesty, self-respect drives valor, and shame protects chastity.",
        category: .character,
        arabicText: nil
    ),
    Saying(
        number: 20,
        text: "Success is the result of foresight and resolution, foresight depends upon deep thinking and planning, and the most important factor of planning is to keep your secrets to yourself.",
        topic: "The path to success",
        explanation: "This outlines a strategic approach to success: it requires vision and determination, which come from careful thought and planning, and discretion is essential to effective planning.",
        category: .wisdom,
        arabicText: nil
    ),
    Saying(
        number: 21,
        text: "Be afraid of the sin which you commit in solitude, when the witness is also the judge.",
        topic: "On private sins",
        explanation: "This warns about sins committed in privacy, reminding that God is both witness and judge. Private conduct reveals true character more than public behavior.",
        category: .faith,
        arabicText: nil
    ),
    Saying(
        number: 22,
        text: "The one who has no control over his desires has no control over his mind.",
        topic: "Self-control and wisdom",
        explanation: "This establishes the link between controlling desires and mental clarity. Without mastery over wants and impulses, one cannot achieve true wisdom or sound judgment.",
        category: .character,
        arabicText: nil
    ),
    Saying(
        number: 23,
        text: "Meet people in such a manner that if you die, they should weep for you, and if you live, they should long for you.",
        topic: "On treating people well",
        explanation: "This beautiful advice on human relations suggests living with such kindness and value that your absence would be mourned and your presence cherished.",
        category: .morality,
        arabicText: nil
    ),
    Saying(
        number: 24,
        text: "When you gain power over your adversary, pardon him by way of thanks for being able to overpower him.",
        topic: "Mercy in victory",
        explanation: "This noble principle advocates showing mercy when victorious as gratitude for success. True strength is demonstrated through forgiveness, not revenge.",
        category: .justice,
        arabicText: nil
    ),
    Saying(
        number: 25,
        text: "The most helpless of all men is he who cannot find a few brothers during his life, and still more helpless is he who finds such brothers but loses them.",
        topic: "The value of friendship",
        explanation: "This highlights the importance of genuine friendships. Those unable to make true friends are pitiful, but even more tragic is losing friends through one's own actions.",
        category: .morality,
        arabicText: nil
    )
]

#Preview {
    NavigationStack {
        SayingsView()
            .background(AppColors.background)
    }
}
