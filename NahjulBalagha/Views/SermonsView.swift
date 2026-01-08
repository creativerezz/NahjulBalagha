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
    @ObservedObject private var repository = ContentRepository.shared
    @State private var searchText = ""
    @State private var selectedCategory: SermonCategory? = nil
    @State private var selectedSermon: Sermon? = nil

    private var filteredSermons: [Sermon] {
        var filtered = repository.sermons

        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        SermonCategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )

                        ForEach(SermonCategory.allCases, id: \.self) { category in
                            SermonCategoryChip(
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

struct SermonCategoryChip: View {
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
                    .italic()

                Text(sermon.excerpt)
                    .font(.body)
                    .foregroundStyle(AppColors.foreground)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct SermonDetailView: View {
    @State private var sermon: Sermon
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 16
    @ObservedObject private var repository = ContentRepository.shared

    init(sermon: Sermon) {
        _sermon = State(initialValue: sermon)
    }

    private var currentIndex: Int? {
        repository.sermons.firstIndex(where: { $0.number == sermon.number })
    }

    private var canGoNext: Bool {
        guard let index = currentIndex else { return false }
        return index < repository.sermons.count - 1
    }

    private var canGoPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    private func goToNext() {
        guard let index = currentIndex, canGoNext else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            sermon = repository.sermons[index + 1]
        }
    }

    private func goToPrevious() {
        guard let index = currentIndex, canGoPrevious else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            sermon = repository.sermons[index - 1]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Sermon \(sermon.number)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)

                            Spacer()

                            // Category Badge
                            Text(sermon.category.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(categoryColor(for: sermon.category).opacity(0.15))
                                )
                                .foregroundStyle(categoryColor(for: sermon.category))
                        }

                        Text(sermon.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.cardForeground)

                        // Topic Card
                        HStack(spacing: 12) {
                            Image(systemName: "text.quote")
                                .font(.title3)
                                .foregroundStyle(AppColors.secondary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Topic")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.mutedForeground)
                                Text(sermon.topic)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppColors.cardForeground)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.muted)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Divider()
                        .padding(.horizontal, 20)

                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Key Passage
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Passage")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)

                            Text(sermon.excerpt)
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

                        // Full Sermon
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Full Sermon")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)

                            Text(sermon.content)
                                .font(.system(size: fontSize, design: .serif))
                                .foregroundStyle(AppColors.foreground)
                                .lineSpacing(6)
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

                        // Only respond to horizontal swipes
                        if abs(horizontal) > abs(vertical) {
                            if horizontal < 0 && canGoNext {
                                // Swipe left -> next
                                goToNext()
                            } else if horizontal > 0 && canGoPrevious {
                                // Swipe right -> previous
                                goToPrevious()
                            }
                        }
                    }
            )
            .navigationTitle("Sermon \(sermon.number)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: "\(sermon.title)\n\n\"\(sermon.excerpt)\"\n\n- Sermon \(sermon.number) from Nahj al-Balagha") {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Menu {
                        Section("Font Size") {
                            Button("Small") { withAnimation { fontSize = 14 } }
                            Button("Medium") { withAnimation { fontSize = 16 } }
                            Button("Large") { withAnimation { fontSize = 18 } }
                            Button("Extra Large") { withAnimation { fontSize = 20 } }
                        }
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                }
            }
        }
    }

    private func categoryColor(for category: SermonCategory) -> Color {
        switch category {
        case .wisdom:
            return AppColors.primary
        case .justice:
            return AppColors.destructive
        case .leadership:
            return AppColors.secondary
        case .faith:
            return AppColors.chart1
        case .governance:
            return AppColors.chart2
        case .morality:
            return AppColors.chart3
        }
    }
}

#Preview {
    NavigationStack { SermonsView() }
}
