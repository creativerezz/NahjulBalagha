import SwiftUI

// MARK: - Data Models

struct Letter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let recipient: String
    let topic: String
    let excerpt: String
    let content: String
    let category: LetterCategory
    let date: String?
}

enum LetterCategory: String, CaseIterable {
    case governance = "Governance"
    case military = "Military"
    case personal = "Personal"
    case instruction = "Instruction"
    case advice = "Advice"
    case rebuke = "Rebuke"
}

// MARK: - Main View

struct LettersView: View {
    @ObservedObject private var repository = ContentRepository.shared
    @State private var searchText = ""
    @State private var selectedCategory: LetterCategory? = nil
    @State private var selectedLetter: Letter? = nil
    
    private var filteredLetters: [Letter] {
        var filtered = repository.letters
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { letter in
                letter.title.localizedCaseInsensitiveContains(searchText) ||
                letter.recipient.localizedCaseInsensitiveContains(searchText) ||
                letter.topic.localizedCaseInsensitiveContains(searchText) ||
                letter.excerpt.localizedCaseInsensitiveContains(searchText) ||
                letter.category.rawValue.localizedCaseInsensitiveContains(searchText)
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
                        
                        ForEach(LetterCategory.allCases, id: \.self) { category in
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
                
                // Letters List
                if filteredLetters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("No letters found")
                            .font(.headline)
                            .foregroundStyle(AppColors.mutedForeground)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
                } else {
                    List(filteredLetters) { letter in
                        LetterRow(letter: letter) {
                            selectedLetter = letter
                        }
                        .listRowBackground(AppColors.background)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search letters...")
                }
            }
        }
        .navigationTitle("Letters")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.background)
        .sheet(item: $selectedLetter) { letter in
            LetterDetailView(letter: letter)
        }
    }
}

// MARK: - Components

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppColors.primary)
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.cardForeground)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? AppColors.primary.opacity(0.12) : AppColors.muted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? AppColors.primary : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Letter Row

struct LetterRow: View {
    let letter: Letter
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Letter \(letter.number)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.primary)
                        
                        Text(letter.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.cardForeground)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Category Badge
                    Text(letter.category.rawValue)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(categoryColor(for: letter.category).opacity(0.15))
                        )
                        .foregroundStyle(categoryColor(for: letter.category))
                }
                
                // Recipient
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text(letter.recipient)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(AppColors.secondary)
                
                // Topic
                Text(letter.topic)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedForeground)
                    .italic()
                
                // Excerpt
                Text(letter.excerpt)
                    .font(.body)
                    .foregroundStyle(AppColors.foreground)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryColor(for category: LetterCategory) -> Color {
        switch category {
        case .governance:
            return AppColors.primary
        case .military:
            return AppColors.destructive
        case .personal:
            return AppColors.chart3
        case .instruction:
            return AppColors.secondary
        case .advice:
            return AppColors.chart1
        case .rebuke:
            return AppColors.chart2
        }
    }
}

// MARK: - Letter Detail View

struct LetterDetailView: View {
    @State private var letter: Letter
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: Double = 16
    @ObservedObject private var repository = ContentRepository.shared

    init(letter: Letter) {
        _letter = State(initialValue: letter)
    }

    private var currentIndex: Int? {
        repository.letters.firstIndex(where: { $0.number == letter.number })
    }

    private var canGoNext: Bool {
        guard let index = currentIndex else { return false }
        return index < repository.letters.count - 1
    }

    private var canGoPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    private func goToNext() {
        guard let index = currentIndex, canGoNext else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            letter = repository.letters[index + 1]
        }
    }

    private func goToPrevious() {
        guard let index = currentIndex, canGoPrevious else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            letter = repository.letters[index - 1]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Letter \(letter.number)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                            
                            Spacer()
                            
                            Text(letter.category.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(categoryColor(for: letter.category).opacity(0.15))
                                )
                                .foregroundStyle(categoryColor(for: letter.category))
                        }
                        
                        Text(letter.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.cardForeground)
                        
                        // Recipient Card
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .font(.title3)
                                .foregroundStyle(AppColors.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("To")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.mutedForeground)
                                Text(letter.recipient)
                                    .font(.headline)
                                    .foregroundStyle(AppColors.cardForeground)
                            }
                            
                            Spacer()
                            
                            if let date = letter.date {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.mutedForeground)
                                    Text(date)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(AppColors.cardForeground)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.muted)
                        )
                        
                        Text(letter.topic)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                            .italic()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Passage")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)
                            
                            Text(letter.excerpt)
                                .font(.system(size: fontSize, weight: .medium, design: .serif))
                                .foregroundStyle(AppColors.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppColors.primary.opacity(0.05))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Full Letter")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.cardForeground)
                            
                            Text(letter.content)
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

                        if abs(horizontal) > abs(vertical) {
                            if horizontal < 0 && canGoNext {
                                goToNext()
                            } else if horizontal > 0 && canGoPrevious {
                                goToPrevious()
                            }
                        }
                    }
            )
            .navigationTitle("Letter \(letter.number)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    ShareLink(item: "\(letter.title)\n\n\(letter.excerpt)\n\n- Letter \(letter.number) to \(letter.recipient)") {
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

    private func categoryColor(for category: LetterCategory) -> Color {
        switch category {
        case .governance:
            return AppColors.primary
        case .military:
            return AppColors.destructive
        case .personal:
            return AppColors.chart3
        case .instruction:
            return AppColors.secondary
        case .advice:
            return AppColors.chart1
        case .rebuke:
            return AppColors.chart2
        }
    }
}

#Preview {
    NavigationStack {
        LettersView()
            .background(AppColors.background)
    }
}

