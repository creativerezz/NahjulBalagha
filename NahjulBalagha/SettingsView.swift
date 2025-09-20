import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var storedDarkMode: Bool = false

    var body: some View {
        List {
            Section("Appearance") {
                Toggle(isOn: $storedDarkMode) {
                    HStack {
                        Image(systemName: storedDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundStyle(AppColors.primary)
                        Text("Dark Mode")
                    }
                }
            }

            Section("About") {
                HStack {
                    Image(systemName: "book")
                        .foregroundStyle(AppColors.secondary)
                    VStack(alignment: .leading) {
                        Text("Nahj al-Balagha")
                            .font(.headline)
                        Text("Sermons, Letters, and Sayings")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(AppColors.background)
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
