//
//  ContentView.swift
//  NahjulBalagha
//
//  Created by Reza Jafar on 9/20/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isDark: Bool = false
    @AppStorage("isDarkMode") private var storedDarkMode: Bool = false

    var body: some View {
        TabView {
            NavigationStack {
                HomeScreen(isDark: $isDark)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                SermonsView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Sermons", systemImage: "book.closed.fill")
            }

            NavigationStack {
                LettersView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Letters", systemImage: "envelope.fill")
            }

            NavigationStack {
                SayingsView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Sayings", systemImage: "quote.bubble.fill")
            }

            NavigationStack {
                SearchView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                SettingsView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(AppColors.primary)
        .preferredColorScheme((isDark || storedDarkMode) ? .dark : .light)
    }
}

private struct HomeScreen: View {
    @Binding var isDark: Bool
    @StateObject private var ai = AIChatService()

    @State private var messages: [ChatMessage] = [
        .init(role: .assistant, text: "Hi! Ask me to search sermons, letters, or sayings. You can also say ‘switch to dark mode’ or ‘open sermons’.")
    ]
    @State private var userInput: String = ""

    @State private var searchResults: [String] = []
    @State private var isShowingSearchSheet: Bool = false
    @State private var quickOpenSection: AppSection? = nil

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

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nahj al-Balagha")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppColors.foreground)
                        Text("Sermons • Letters • Sayings")
                            .font(.headline)
                            .foregroundStyle(AppColors.mutedForeground)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal)

                    ChatPanel(
                        messages: $messages,
                        userInput: $userInput,
                        onSend: handleUserMessage
                    )
                    .overlay(alignment: .topTrailing) {
                        Group {
                            switch ai.availability {
                            case .available:
                                Label(ai.currentProvider.displayName, systemImage: ai.currentProvider.icon)
                                    .foregroundStyle(AppColors.mutedForeground)
                                    .font(.caption2)
                            case .unavailable(let reason):
                                Label("AI off", systemImage: "slash.circle")
                                    .foregroundStyle(AppColors.mutedForeground)
                                    .font(.caption2)
                                    .help(reason ?? "AI unavailable")
                            }
                        }
                        .padding(8)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        NavigationLink { SermonsView() } label: {
                            SectionCard(title: "Sermons", subtitle: "Eloquent discourses", symbol: "book.closed.fill", tint: AppColors.primary)
                        }
                        .buttonStyle(.plain)

                        NavigationLink { LettersView() } label: {
                            SectionCard(title: "Letters", subtitle: "Guidance in correspondence", symbol: "envelope.fill", tint: AppColors.secondary)
                        }
                        .buttonStyle(.plain)

                        NavigationLink { SayingsView() } label: {
                            SectionCard(title: "Sayings", subtitle: "Wise aphorisms", symbol: "quote.bubble.fill", tint: AppColors.chart2)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 12)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isDark.toggle()
                    UserDefaults.standard.set(isDark, forKey: "isDarkMode")
                } label: {
                    Image(systemName: isDark ? "sun.max.fill" : "moon.fill")
                }
                .accessibilityLabel(isDark ? "Switch to Light Mode" : "Switch to Dark Mode")
            }
        }
        .onAppear {
            if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
                isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
            }
        }
        .sheet(isPresented: $isShowingSearchSheet) {
            NavigationStack {
                List(searchResults, id: \.self) { item in
                    Text(item)
                        .foregroundStyle(AppColors.foreground)
                }
                .listStyle(.insetGrouped)
                .background(AppColors.background)
                .navigationTitle("Search Results")
            }
        }
        .sheet(item: $quickOpenSection) { section in
            switch section {
            case .sermons:
                NavigationStack { SermonsView().background(AppColors.background) }
            case .letters:
                NavigationStack { LettersView().background(AppColors.background) }
            case .sayings:
                NavigationStack { SayingsView().background(AppColors.background) }
            }
        }
    }

    private func handleUserMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(.init(role: .user, text: trimmed))

        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, role: .assistant, text: ""))

        let lower = trimmed.lowercased()

        Task { @MainActor in
            ai.makeToolEnabledSession(openHandler: { section in
                quickOpenSection = section
            }, setDarkMode: { dark in
                isDark = dark
                UserDefaults.standard.set(dark, forKey: "isDarkMode")
            })

            if ai.isAvailable {
                var lastPartial = AssistantTurn.PartialTurn()
                do {
                    for try await partial in ai.streamTurn(for: trimmed) {
                        lastPartial = partial
                        if let reply = partial.reply,
                           let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                            messages[index] = ChatMessage(id: placeholderID, role: .assistant, text: reply)
                        }
                    }

                    if let results = lastPartial.searchResults, !results.isEmpty {
                        searchResults = Array(results.prefix(20))
                        isShowingSearchSheet = true
                    }

                    if let action = lastPartial.action {
                        switch action.command {
                        case "openSermons": quickOpenSection = .sermons
                        case "openLetters": quickOpenSection = .letters
                        case "openSayings": quickOpenSection = .sayings
                        case "setDarkMode":
                            if let b = action.bool {
                                isDark = b
                                UserDefaults.standard.set(b, forKey: "isDarkMode")
                            }
                        default: break
                        }
                    }
                } catch {
                    if let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                        messages.remove(at: index)
                    }
                    fallbackLocalHandling(lower: lower, original: trimmed)
                    return
                }
            } else {
                if let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                    messages.remove(at: index)
                }
                fallbackLocalHandling(lower: lower, original: trimmed)
                return
            }

            if let index = messages.firstIndex(where: { $0.id == placeholderID }), messages[index].text.isEmpty {
                messages[index] = .init(id: placeholderID, role: .assistant, text: "Okay.")
            }
        }
    }

    private func fallbackLocalHandling(lower: String, original: String) {
        if lower.contains("dark") || lower.contains("light mode") {
            let targetDark = lower.contains("dark") && !lower.contains("light")
            isDark = targetDark ? true : (lower.contains("light") ? false : isDark)
            UserDefaults.standard.set(isDark, forKey: "isDarkMode")
            messages.append(.init(role: .assistant, text: isDark ? "Switched to dark mode." : "Switched to light mode."))
            return
        }

        if lower.contains("open sermons") || lower.contains("go to sermons") || lower.contains("sermons") {
            quickOpenSection = .sermons
            messages.append(.init(role: .assistant, text: "Opening Sermons…"))
            return
        }
        if lower.contains("open letters") || lower.contains("go to letters") || lower.contains("letters") {
            quickOpenSection = .letters
            messages.append(.init(role: .assistant, text: "Opening Letters…"))
            return
        }
        if lower.contains("open sayings") || lower.contains("go to sayings") || lower.contains("sayings") {
            quickOpenSection = .sayings
            messages.append(.init(role: .assistant, text: "Opening Sayings…"))
            return
        }

        let results = allItems.filter { $0.localizedCaseInsensitiveContains(original) }
        searchResults = Array(results.prefix(20))
        if searchResults.isEmpty {
            messages.append(.init(role: .assistant, text: "I couldn’t find anything for ‘\(original)’. Try another term like ‘justice’ or ‘patience’."))
        } else {
            messages.append(.init(role: .assistant, text: "Found \(searchResults.count) result(s) for ‘\(original)’. Showing the first \(searchResults.count)."))
            isShowingSearchSheet = true
        }
    }
}

private struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id: UUID
    let role: Role
    var text: String

    init(id: UUID = UUID(), role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

private struct ChatPanel: View {
    @Binding var messages: [ChatMessage]
    @Binding var userInput: String
    var onSend: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ask Nahj Assistant")
                .font(.headline)
                .foregroundStyle(AppColors.cardForeground)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(messages) { msg in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: msg.role == .assistant ? "sparkles" : "person.fill")
                            .font(.subheadline)
                            .foregroundStyle(msg.role == .assistant ? AppColors.secondary : AppColors.primary)
                        Text(msg.text)
                            .foregroundStyle(AppColors.foreground)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(msg.role == .assistant ? AppColors.card : AppColors.card.opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        Spacer(minLength: 0)
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Ask to search or change settings…", text: $userInput, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.card.opacity(0.95))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                Button {
                    let text = userInput
                    userInput = ""
                    onSend(text)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.headline)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct SectionCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(tint.gradient)
                    .frame(width: 56, height: 56)
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.primaryForeground)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColors.cardForeground)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedForeground)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(AppColors.mutedForeground)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
