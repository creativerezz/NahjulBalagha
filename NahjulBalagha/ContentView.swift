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
            // Home Tab
            NavigationStack {
                HomeScreen(isDark: $isDark)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // Sermons Tab
            NavigationStack {
                SermonsView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Sermons", systemImage: "book.closed.fill")
            }

            // Letters Tab
            NavigationStack {
                LettersView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Letters", systemImage: "envelope.fill")
            }

            // Sayings Tab
            NavigationStack {
                SayingsView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Sayings", systemImage: "quote.bubble.fill")
            }

            // Search Tab
            NavigationStack {
                SearchView()
                    .background(AppColors.background)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            // Settings Tab
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

    var body: some View {
        ZStack {
            // Background fill using theme
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
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

                    // Cards
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
            // Sync the binding with stored setting on first show
            if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
                isDark = UserDefaults.standard.bool(forKey: "isDarkMode")
            }
        }
    }
}

// MARK: - Components
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
