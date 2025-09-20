import SwiftUI

struct AppSettingsView: View {
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
                .onChange(of: storedDarkMode) { _, newValue in
                    // Persist is automatic with @AppStorage, but this helps sync other bindings if needed
                    UserDefaults.standard.set(newValue, forKey: "isDarkMode")
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
    NavigationStack { AppSettingsView() }
}
