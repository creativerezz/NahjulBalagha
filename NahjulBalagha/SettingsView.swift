import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var storedDarkMode: Bool = false
    @AppStorage("openrouter_api_key") private var openRouterApiKey: String = ""
    @StateObject private var aiService = AIChatService()
    @State private var showingApiKeyAlert = false

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

            Section("AI Assistant") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Provider")
                        .font(.headline)

                    ForEach(AIProvider.allCases) { provider in
                        AIProviderRow(
                            provider: provider,
                            isSelected: aiService.currentProvider == provider,
                            availability: providerAvailability(provider),
                            onSelect: {
                                aiService.setProvider(provider)
                            }
                        )
                    }
                }
                .padding(.vertical, 4)

                if aiService.currentProvider == .openRouter {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Model")
                            .font(.subheadline.weight(.medium))

                        Picker("Select Model", selection: Binding(
                            get: { aiService.selectedModel },
                            set: { aiService.setModel($0) }
                        )) {
                            ForEach(OpenRouterConfig.availableModels, id: \.self) { model in
                                Text(model.replacingOccurrences(of: "/", with: " / "))
                                    .tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.top, 8)
                }

                if aiService.currentProvider == .openRouter {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("API Key")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Button("Help") {
                                showingApiKeyAlert = true
                            }
                            .font(.caption)
                            .foregroundStyle(AppColors.secondary)
                        }

                        SecureField("Enter OpenRouter API Key", text: $openRouterApiKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: openRouterApiKey) { _, newValue in
                                OpenRouterConfig.setApiKey(newValue)
                                aiService.updateAvailability()
                            }

                        if openRouterApiKey.isEmpty {
                            Text("API key required for OpenRouter")
                                .font(.caption)
                                .foregroundStyle(AppColors.destructive)
                        } else {
                            Text("API key configured ✓")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondary)
                        }
                    }
                    .padding(.top, 8)
                }

                HStack {
                    Image(systemName: aiService.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(aiService.isAvailable ? AppColors.secondary : AppColors.destructive)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Status")
                            .font(.subheadline.weight(.medium))

                        if case .unavailable(let reason) = aiService.availability {
                            Text(reason ?? "Unavailable")
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedForeground)
                        } else {
                            Text("Ready")
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedForeground)
                        }
                    }
                }
                .padding(.top, 8)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundStyle(AppColors.primary)
                .accessibilityLabel("Back")
            }
        }
        .alert("OpenRouter API Key", isPresented: $showingApiKeyAlert) {
            Button("OK") { }
        } message: {
            Text("1. Sign up at openrouter.ai\n2. Go to your dashboard\n3. Generate an API key\n4. Paste it here\n\nYour key is stored securely on device.")
        }
        .onAppear {
            openRouterApiKey = OpenRouterConfig.apiKey
            aiService.updateAvailability()
        }
    }

    private func providerAvailability(_ provider: AIProvider) -> String {
        switch provider {
        case .foundationModels:
            #if canImport(FoundationModels)
            return "Available on supported devices"
            #else
            return "Not available on this platform"
            #endif
        case .openRouter:
            return openRouterApiKey.isEmpty ? "Requires API key" : "Ready"
        case .localStub:
            return "Always available"
        }
    }
}

struct AIProviderRow: View {
    let provider: AIProvider
    let isSelected: Bool
    let availability: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: provider.icon)
                    .foregroundStyle(isSelected ? AppColors.primary : AppColors.mutedForeground)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.cardForeground)

                    Text(provider.description)
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)

                    Text(availability)
                        .font(.caption2)
                        .foregroundStyle(AppColors.mutedForeground)
                        .italic()
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.primary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
