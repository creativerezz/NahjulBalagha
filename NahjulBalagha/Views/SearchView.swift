import SwiftUI

struct SearchView: View {
    @ObservedObject private var repository = ContentRepository.shared
    @State private var query: String = ""
    @State private var selectedResult: SearchResult? = nil
    
    private var searchResults: [SearchResult] {
        repository.search(query)
    }
    
    var body: some View {
        Group {
            if query.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.mutedForeground)
                    Text("Search Nahj al-Balagha")
                        .font(.headline)
                        .foregroundStyle(AppColors.cardForeground)
                    Text("Search across all sermons, letters, and sayings")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.mutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            } else if searchResults.isEmpty {
                // No results state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.mutedForeground)
                    Text("No results found")
                        .font(.headline)
                        .foregroundStyle(AppColors.cardForeground)
                    Text("Try different search terms")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.mutedForeground)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            } else {
                // Results list
                List(searchResults) { result in
                    Button {
                        selectedResult = result
                    } label: {
                        SearchResultRow(result: result)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(AppColors.background)
                }
                .listStyle(.plain)
                .background(AppColors.background)
            }
        }
        .navigationTitle("Search")
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search Nahj al-Balagha"
        )
        .sheet(item: $selectedResult) { result in
            NavigationStack {
                resultDetailView(for: result)
            }
        }
    }
    
    @ViewBuilder
    private func resultDetailView(for result: SearchResult) -> some View {
        switch result {
        case .sermon(let sermon):
            SermonDetailView(sermon: sermon)
        case .letter(let letter):
            LetterDetailView(letter: letter)
        case .saying(let saying):
            SayingDetailView(
                saying: saying,
                isFavorite: false,
                toggleFavorite: { }
            )
        }
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with type and category
            HStack {
                Text(result.contentType)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                
                Spacer()
                
                Text(result.categoryName)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppColors.secondary.opacity(0.15))
                    )
                    .foregroundStyle(AppColors.secondary)
            }
            
            // Title
            Text(result.displayTitle)
                .font(.headline)
                .foregroundStyle(AppColors.cardForeground)
                .multilineTextAlignment(.leading)
            
            // Excerpt
            Text(result.excerpt)
                .font(.body)
                .foregroundStyle(AppColors.foreground)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack { SearchView() }
}
