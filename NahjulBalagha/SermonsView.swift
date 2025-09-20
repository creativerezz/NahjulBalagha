import SwiftUI

struct Sermon: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let topic: String
    let excerpt: String
    let content: String
    let category: SermonCategory
}

enum SermonCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case justice = "Justice"
    case leadership = "Leadership"
    case faith = "Faith"
    case governance = "Governance"
    case morality = "Morality"
}

struct SermonsView: View {
    @State private var searchText = ""
    @State private var selectedCategory: SermonCategory? = nil
    @State private var selectedSermon: Sermon? = nil
    
    private let sermons: [Sermon] = [
        // Featured/Popular Sermons
        Sermon(
            number: 1,
            title: "The Nature of Wisdom",
            topic: "On the pursuit of knowledge and understanding",
            excerpt: "He who has a thousand friends has not a friend to spare, and he who has one enemy will meet him everywhere.",
            content: "This is the full content of the first sermon about wisdom and knowledge...",
            category: .wisdom
        ),
        Sermon(
            number: 2,
            title: "Justice and Leadership",
            topic: "On the responsibilities of rulers",
            excerpt: "Justice is the cornerstone of leadership, and mercy its foundation.",
            content: "The complete text of the sermon on justice and leadership...",
            category: .justice
        ),
        Sermon(
            number: 3,
            title: "The Path of Righteousness",
            topic: "On moral conduct and spiritual guidance",
            excerpt: "The path of righteousness is narrow, but it leads to eternal peace.",
            content: "Full sermon text about righteousness and moral conduct...",
            category: .morality
        ),
        Sermon(
            number: 4,
            title: "Governance and Responsibility",
            topic: "On the duties of those in authority",
            excerpt: "Authority without justice is tyranny; justice without authority is powerless.",
            content: "Complete sermon on governance and the responsibilities of leadership...",
            category: .governance
        ),
        Sermon(
            number: 5,
            title: "Faith and Devotion",
            topic: "On spiritual devotion and trust in Allah",
            excerpt: "True faith is tested not in ease, but in hardship and adversity.",
            content: "Full text of the sermon on faith, devotion, and trust in Allah...",
            category: .faith
        )
    ] + (6...50).map { i in
        let categories: [SermonCategory] = [.wisdom, .justice, .leadership, .faith, .governance, .morality]
        let category = categories[i % categories.count]
        return Sermon(
            number: i,
            title: "Sermon \(i): \(category.rawValue) and Guidance",
            topic: "On \(category.rawValue.lowercased()) and spiritual matters",
            excerpt: "An excerpt from sermon \(i) discussing \(category.rawValue.lowercased()) and related matters.",
            content: "This is the full content of sermon number \(i)...",
            category: category
        )
    }
    
    private var filteredSermons: [Sermon] {
        var filtered = sermons
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { sermon in
                sermon.title.localizedCaseInsensitiveContains(searchText) ||
                sermon.topic.localizedCaseInsensitiveContains(searchText) ||
                sermon.excerpt.localizedCaseInsensitiveContains(searchText) ||
                sermon.category.rawValue.localizedCaseInsensitiveContains(searchText)
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
                        
                        ForEach(SermonCategory.allCases, id: \.self) { category in
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
                
                // Sermons List
                List(filteredSermons) { sermon in
                    SermonRow(sermon: sermon) {
                        selectedSermon = sermon
                    }
                    .listRowBackground(AppColors.background)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search sermons...")
            }
        }
        .navigationTitle("Sermons")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.background)
        .sheet(item: $selectedSermon) { sermon in
            SermonDetailView(sermon: sermon)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isSelected ? AppColors.primary : AppColors.muted)
                )
                .foregroundStyle(isSelected ? AppColors.primaryForeground : AppColors.mutedForeground)
        }
        .buttonStyle(.plain)
    }
}

struct SermonRow: View {
    let sermon: Sermon
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sermon \(sermon.number)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.primary)
                        
                        Text(sermon.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.cardForeground)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Text(sermon.category.rawValue)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppColors.secondary.opacity(0.15))
                        )
                        .foregroundStyle(AppColors.secondary)
                }
                
                Text(sermon.topic)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedForeground)
                    .multilineTextAlignment(.leading)
                
                Text(sermon.excerpt)
                    .font(.body)
                    .foregroundStyle(AppColors.foreground)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct SermonDetailView: View {
    let sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 16
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Sermon \(sermon.number)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                            
                            Spacer()
                            
                            Text(sermon.category.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppColors.secondary.opacity(0.15))
                                )
                                .foregroundStyle(AppColors.secondary)
                        }
                        
                        Text(sermon.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.cardForeground)
                        
                        Text(sermon.topic)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                            .italic()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Excerpt")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColors.cardForeground)
                        
                        Text(sermon.excerpt)
                            .font(.system(size: fontSize, weight: .medium, design: .serif))
                            .foregroundStyle(AppColors.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.muted)
                            )
                        
                        Text("Full Sermon")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColors.cardForeground)
                            .padding(.top, 8)
                        
                        Text(sermon.content)
                            .font(.system(size: fontSize, design: .serif))
                            .foregroundStyle(AppColors.foreground)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Sermon Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Font Size") {
                            Button("Small") { fontSize = 14 }
                            Button("Medium") { fontSize = 16 }
                            Button("Large") { fontSize = 18 }
                            Button("Extra Large") { fontSize = 20 }
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { 
        SermonsView()
            .background(AppColors.background)
    }
}
