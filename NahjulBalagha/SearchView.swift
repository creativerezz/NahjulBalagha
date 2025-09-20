import SwiftUI

struct SearchView: View {
    @State private var query: String = ""

    // Placeholder data; replace with real data later
    private let allItems: [String] = (
        ["Sermon 1: The Nature of Wisdom",
         "Sermon 2: Justice and Leadership",
         "Letter 1: To Malik al-Ashtar",
         "Letter 2: Counsel and Governance",
         "Saying 1: On Knowledge and Action",
         "Saying 2: On Patience and Gratitude"]
        + (3...20).map { "Sermon \($0)" }
        + (3...30).map { "Letter \($0)" }
        + (3...50).map { "Saying \($0)" }
    )

    var filteredItems: [String] {
        guard !query.isEmpty else { return allItems }
        return allItems.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List(filteredItems, id: \.self) { item in
            Text(item)
                .foregroundStyle(AppColors.foreground)
        }
        .listStyle(.insetGrouped)
        .background(AppColors.background)
        .navigationTitle("Search")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search Nahj al-Balagha")
    }
}

#Preview {
    NavigationStack { SearchView() }
}
