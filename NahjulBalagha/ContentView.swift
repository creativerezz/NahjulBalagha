import SwiftUI

private enum AppTab: Hashable {
    case library
    case settings
}

struct ContentView: View {
    @State private var library: SermonLibrary
    @State private var selectedTab: AppTab = .library

    init(api: any SermonProviding = NahjulBalaghaAPI()) {
        _library = State(initialValue: SermonLibrary(api: api))
    }

    var body: some View {
        @Bindable var library = library

        TabView(selection: $selectedTab) {
            Tab("Library", systemImage: "books.vertical", value: AppTab.library) {
                LibraryTab(library: library)
            }

            Tab("Settings", systemImage: "textformat.size", value: AppTab.settings) {
                SettingsTab(library: library)
            }
        }
        .tint(.teal)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory(isEnabled: library.currentSummary != nil) {
            if let summary = library.currentSummary {
                ContinueReadingAccessory(summary: summary) {
                    selectedTab = .library
                    library.selectedSummary = summary
                }
            }
        }
        .task {
            await library.loadInitialSermons()
        }
    }
}

// MARK: - Library Tab

private struct LibraryTab: View {
    let library: SermonLibrary

    var body: some View {
        @Bindable var library = library

        NavigationStack {
            SermonListView(library: library)
                .navigationTitle("Nahj al-Balagha")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $library.searchText, prompt: "Search sermons")
                .onChange(of: library.searchText) {
                    library.refreshForCurrentFilters()
                }
                .navigationDestination(item: $library.selectedSummary) { summary in
                    SermonReaderScreen(library: library, summary: summary)
                }
        }
    }
}

/// Loads and hosts the reader for a pushed sermon, hiding the tab bar so the
/// reading experience is full-screen.
private struct SermonReaderScreen: View {
    let library: SermonLibrary
    let summary: SermonSummary

    var body: some View {
        SermonDetailView(library: library)
            .task(id: summary.id) {
                await library.showDetail(for: summary)
            }
            .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Sermon List

private struct SermonListView: View {
    let library: SermonLibrary

    var body: some View {
        @Bindable var library = library

        List {
            Section {
                LibraryMasthead(library: library)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            .listRowSeparator(.hidden)

            Section {
                LanguageFilter(library: library)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 12, trailing: 16))
            .listRowSeparator(.hidden)

            if library.isLoadingList && library.sermons.isEmpty {
                Section {
                    LoadingRow(title: "Loading sermons")
                        .listRowSeparator(.hidden)
                }
                .listRowBackground(Color.clear)
            } else if library.sermons.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Sermons Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a broader search term.")
                    )
                    .listRowSeparator(.hidden)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(library.sermons) { sermon in
                        Button {
                            library.selectedSummary = sermon
                        } label: {
                            SermonRow(summary: sermon)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    LibrarySectionHeader(title: summaryLabel, count: library.totalCount)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(HomeBackground())
        .overlay(alignment: .bottom) {
            if library.isLoadingList && !library.sermons.isEmpty {
                ProgressView()
                    .padding(14)
                    .glassEffect()
                    .padding(.bottom, 12)
            }
        }
    }

    private var summaryLabel: String {
        library.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Library" : "Results"
    }
}

// MARK: - Library Masthead

/// The branded hero at the top of the home screen: an Arabic wordmark, the
/// romanized title in the same serif face used by the reader, a one-line
/// description, and the primary "random sermon" action.
private struct LibraryMasthead: View {
    let library: SermonLibrary

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("نَهْج ٱلْبَلَاغَة")
                    .font(.system(.title2, design: .serif).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .environment(\.layoutDirection, .rightToLeft)

                Text("Nahj al-Balagha")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(.white)

                Text("Peak of Eloquence — 240 sermons of Imam Ali ibn Abi Talib")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                Task { await library.loadRandom() }
            } label: {
                Label("Open a Random Sermon", systemImage: "shuffle")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.mastheadInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.white, in: Capsule())
                    .opacity(library.isLoadingDetail ? 0.6 : 1)
            }
            .buttonStyle(.plain)
            .disabled(library.isLoadingDetail)
            .accessibilityHint("Opens a randomly selected sermon")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.mastheadTop, .mastheadBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    // A faint decorative glyph adds warmth without clutter.
                    Image(systemName: "book.pages")
                        .font(.system(size: 116))
                        .foregroundStyle(.white.opacity(0.06))
                        .offset(x: 26, y: -20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Language Filter

private struct LanguageFilter: View {
    let library: SermonLibrary

    var body: some View {
        Picker("Language", selection: languageBinding) {
            ForEach(SermonLanguage.allCases) { language in
                Label(language.title, systemImage: language.symbolName)
                    .tag(language)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Library language")
    }

    private var languageBinding: Binding<SermonLanguage> {
        Binding {
            library.language
        } set: { newValue in
            library.setLanguage(newValue)
        }
    }
}

// MARK: - Library Section Header

private struct LibrarySectionHeader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Text("\(count)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(.teal)
        }
        .textCase(nil)
        .padding(.top, 4)
    }
}

// MARK: - Sermon Row

private struct SermonRow: View {
    let summary: SermonSummary

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // A slim rule plus a serif numeral evokes a manuscript margin.
            HStack(spacing: 10) {
                Capsule()
                    .fill(Color.teal.opacity(0.5))
                    .frame(width: 3)

                Text("\(summary.id)")
                    .font(.system(.title3, design: .serif).weight(.semibold).monospacedDigit())
                    .foregroundStyle(.teal)
                    .frame(minWidth: 30, alignment: .trailing)
            }
            .fixedSize()

            VStack(alignment: .leading, spacing: 6) {
                Text(summary.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(summary.titleArabic)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)

                if let snippet = summary.cleanSnippet {
                    Text(snippet)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 6) {
                    Label("\(summary.estimatedReadMinutes) min", systemImage: "clock")
                    Text("·")
                    Text("\(summary.wordCount) words")
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(summary.title), Sermon \(summary.id), \(summary.estimatedReadMinutes) minute read")
    }
}

// MARK: - Home Background

private struct HomeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemGroupedBackground),
                Color.teal.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Continue Reading Accessory

/// A compact "now reading" bar shown above the Liquid Glass tab bar (the
/// system supplies the glass background). Tapping it reopens the reader.
private struct ContinueReadingAccessory: View {
    let summary: SermonSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text("\(summary.id)")
                    .font(.system(.subheadline, design: .serif).weight(.semibold).monospacedDigit())
                    .foregroundStyle(.teal)
                    .frame(minWidth: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Continue Reading")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(summary.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "book.pages")
                    .font(.body)
                    .foregroundStyle(.teal)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Continue reading sermon \(summary.id), \(summary.title)")
    }
}

// MARK: - Settings Tab

private struct SettingsTab: View {
    let library: SermonLibrary

    var body: some View {
        @Bindable var library = library

        NavigationStack {
            Form {
                Section("Reader Theme") {
                    Picker("Theme", selection: $library.readerTheme) {
                        ForEach(ReaderTheme.allCases) { theme in
                            Label(theme.title, systemImage: theme.symbolName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Text Size") {
                    HStack {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundStyle(.secondary)
                        Slider(
                            value: $library.readerFontSize,
                            in: SermonLibrary.fontSizeRange,
                            step: 1
                        )
                        .tint(.teal)
                        Image(systemName: "textformat.size.larger")
                            .foregroundStyle(.secondary)
                    }

                    Text("The quick brown fox")
                        .font(.system(size: library.readerFontSize, weight: .regular, design: .serif))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }

                Section {
                    Toggle("Show Section Text", isOn: $library.showsSubsections)
                } footer: {
                    Text("Displays each sermon's individual passages beneath the full text.")
                }

                Section("About") {
                    LabeledContent("Collection", value: "Nahj al-Balagha")
                    LabeledContent("Sermons", value: "\(library.totalCount)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Detail View

private struct SermonDetailView: View {
    let library: SermonLibrary

    var body: some View {
        ZStack {
            library.readerTheme.background.ignoresSafeArea()

            if library.isLoadingDetail && library.selectedSermon == nil {
                LoadingReader(theme: library.readerTheme)
            } else if let sermon = library.selectedSermon {
                SermonReader(sermon: sermon, library: library)
            } else {
                ContentUnavailableView(
                    "Select a Sermon",
                    systemImage: "book.closed",
                    description: Text("Choose a sermon from the library to begin reading.")
                )
                .foregroundStyle(library.readerTheme.primaryText)
            }
        }
        .overlay(alignment: .top) {
            if let errorMessage = library.errorMessage {
                ErrorBanner(message: errorMessage, theme: library.readerTheme)
                    .padding(.top, 10)
            } else if library.isLoadingDetail, library.selectedSermon != nil {
                ProgressView()
                    .padding(14)
                    .glassEffect()
                    .padding(.top, 10)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if library.selectedSermon != nil {
                ReadingControlBar(library: library)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Sermon Reader

private struct SermonReader: View {
    let sermon: Sermon
    let library: SermonLibrary

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Color.clear.frame(height: 1).id("top")

                    ReaderHeader(sermon: sermon, theme: library.readerTheme)

                    if library.showsSubsections && !sermon.subsections.isEmpty {
                        SectionNavigator(
                            subsections: sermon.subsections,
                            theme: library.readerTheme
                        ) { subsection in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(subsection.id, anchor: .top)
                            }
                        }
                    }

                    Text(activeText)
                        .font(.system(size: activeFontSize, weight: .regular, design: .serif))
                        .lineSpacing(language == .arabic ? 10 : 8)
                        .foregroundStyle(library.readerTheme.primaryText)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)

                    if library.showsSubsections && !sermon.subsections.isEmpty {
                        SubsectionList(
                            subsections: sermon.subsections,
                            language: language,
                            fontSize: activeFontSize - 1,
                            theme: library.readerTheme
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 110)
                .frame(maxWidth: 780, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Sermon \(sermon.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .accessibilityLabel("Scroll to top")
                }
            }
        }
    }

    private var language: SermonLanguage {
        library.language
    }

    private var activeFontSize: Double {
        language == .arabic ? library.readerFontSize + 2 : library.readerFontSize
    }

    private var activeText: String {
        switch language {
        case .english: sermon.englishText
        case .arabic: sermon.arabicText
        }
    }
}

// MARK: - Reader Header

private struct ReaderHeader: View {
    let sermon: Sermon
    let theme: ReaderTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Label("Sermon \(sermon.id)", systemImage: "book.pages")
                Text("·")
                Label("\(sermon.estimatedReadMinutes) min read", systemImage: "clock")
                Text("·")
                Label("\(sermon.wordCount) words", systemImage: "text.word.spacing")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(theme.secondaryText)
            .labelStyle(.titleAndIcon)
            .accessibilityElement(children: .combine)

            VStack(alignment: .leading, spacing: 14) {
                Text(sermon.title)
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(sermon.titleArabic)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)
            }

            if let sourceURL = sermon.sourceURL {
                Link(destination: sourceURL) {
                    Label("Open source", systemImage: "safari")
                        .font(.callout.weight(.medium))
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Open source website for this sermon")
            }
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Section Navigator

private struct SectionNavigator: View {
    let subsections: [SermonSubsection]
    let theme: ReaderTheme
    let onSelect: (SermonSubsection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In this sermon")
                .font(.callout.weight(.semibold))
                .foregroundStyle(theme.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(subsections.prefix(8)) { subsection in
                        Button {
                            onSelect(subsection)
                        } label: {
                            Text(subsection.title)
                                .font(.footnote.weight(.medium))
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(theme.controlFill, in: Capsule())
                                .foregroundStyle(theme.primaryText)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Scrolls to this section")
                    }
                }
            }
        }
    }
}

// MARK: - Subsection List

private struct SubsectionList: View {
    let subsections: [SermonSubsection]
    let language: SermonLanguage
    let fontSize: Double
    let theme: ReaderTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Section Text")
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.primaryText)

            ForEach(subsections) { subsection in
                DisclosureGroup {
                    Text(language == .arabic ? subsection.arabic : subsection.english)
                        .font(.system(size: fontSize, weight: .regular, design: .serif))
                        .lineSpacing(7)
                        .foregroundStyle(theme.primaryText)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)
                        .padding(.top, 8)
                } label: {
                    Text(subsection.title)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)
                }
                .padding(16)
                .background(theme.sectionFill, in: RoundedRectangle(cornerRadius: 8))
                .id(subsection.id)
            }
        }
    }
}

// MARK: - Reading Control Bar

private struct ReadingControlBar: View {
    let library: SermonLibrary

    var body: some View {
        @Bindable var library = library

        HStack(spacing: 10) {
            Picker("Language", selection: languageBinding) {
                ForEach(SermonLanguage.allCases) { language in
                    Image(systemName: language.symbolName).tag(language)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 128)
            .accessibilityLabel("Reader language")

            Divider().frame(height: 28)

            Button {
                library.decreaseReaderFont()
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .disabled(library.readerFontSize <= SermonLibrary.fontSizeRange.lowerBound)
            .accessibilityLabel("Decrease font size")

            Text("\(Int(library.readerFontSize))")
                .font(.callout.monospacedDigit().weight(.semibold))
                .frame(width: 28)
                .accessibilityLabel("Font size: \(Int(library.readerFontSize)) points")

            Button {
                library.increaseReaderFont()
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .disabled(library.readerFontSize >= SermonLibrary.fontSizeRange.upperBound)
            .accessibilityLabel("Increase font size")

            Divider().frame(height: 28)

            Menu {
                Picker("Theme", selection: $library.readerTheme) {
                    ForEach(ReaderTheme.allCases) { theme in
                        Label(theme.title, systemImage: theme.symbolName).tag(theme)
                    }
                }

                Toggle("Show Section Text", isOn: $library.showsSubsections)
            } label: {
                Image(systemName: library.readerTheme.symbolName)
            }
            .accessibilityLabel("Reader settings")
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var languageBinding: Binding<SermonLanguage> {
        Binding {
            library.language
        } set: { newValue in
            library.setLanguage(newValue)
        }
    }
}

// MARK: - Loading & Error Views

private struct LoadingReader: View {
    let theme: ReaderTheme

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading sermon")
                .font(.callout.weight(.medium))
        }
        .foregroundStyle(theme.secondaryText)
    }
}

private struct LoadingRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(title)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}

private struct ErrorBanner: View {
    let message: String
    let theme: ReaderTheme

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(.footnote.weight(.medium))
            .foregroundStyle(theme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))
            .padding(.horizontal)
    }
}

// MARK: - Home Palette

private extension Color {
    /// Deep teal gradient endpoints for the branded masthead.
    static let mastheadTop = Color(red: 0.05, green: 0.42, blue: 0.44)
    static let mastheadBottom = Color(red: 0.02, green: 0.22, blue: 0.30)
    /// Ink color for text sitting on the white masthead button.
    static let mastheadInk = Color(red: 0.02, green: 0.22, blue: 0.30)
}

// MARK: - Reader Theme Colors

private extension ReaderTheme {
    var background: Color {
        switch self {
        case .paper: Color(uiColor: .systemBackground)
        case .sepia: Color(red: 0.96, green: 0.92, blue: 0.84)
        case .night: Color(red: 0.08, green: 0.09, blue: 0.10)
        }
    }

    var primaryText: Color {
        switch self {
        case .paper: Color.primary
        case .sepia: Color(red: 0.18, green: 0.13, blue: 0.08)
        case .night: Color(red: 0.89, green: 0.90, blue: 0.86)
        }
    }

    var secondaryText: Color {
        switch self {
        case .paper: Color.secondary
        case .sepia: Color(red: 0.39, green: 0.30, blue: 0.20)
        case .night: Color(red: 0.66, green: 0.70, blue: 0.68)
        }
    }

    var controlFill: Color {
        switch self {
        case .paper: Color.teal.opacity(0.10)
        case .sepia: Color(red: 0.80, green: 0.68, blue: 0.48).opacity(0.32)
        case .night: Color.teal.opacity(0.18)
        }
    }

    var sectionFill: Color {
        switch self {
        case .paper: Color.secondary.opacity(0.08)
        case .sepia: Color.white.opacity(0.32)
        case .night: Color.white.opacity(0.07)
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView(api: PreviewSermonProvider())
}

#Preview("Reader") {
    ReaderPreviewHost()
}

private struct ReaderPreviewHost: View {
    @State private var library = SermonLibrary(api: PreviewSermonProvider())

    var body: some View {
        SermonReader(sermon: .preview, library: library)
            .background(library.readerTheme.background)
    }
}

private struct PreviewSermonProvider: SermonProviding {
    func listSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonListResponse {
        SermonListResponse(total: 1, limit: limit, offset: offset, count: 1, sermons: [Sermon.preview.summary])
    }

    func searchSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonSearchResponse {
        SermonSearchResponse(query: query, lang: language.rawValue, total: 1, limit: limit, offset: offset, results: [Sermon.preview.summary])
    }

    func sermon(id: Int) async throws -> Sermon { .preview }

    func randomSermon() async throws -> Sermon { .preview }
}

private extension Sermon {
    var summary: SermonSummary {
        SermonSummary(
            id: id,
            title: title,
            titleArabic: titleArabic,
            wordCount: wordCount,
            snippet: String(englishText.prefix(120))
        )
    }
}

private extension Sermon {
    static let preview = Sermon(
        id: 1,
        title: "Praise is due to Allah whose worth cannot be described",
        titleArabic: "الحمد لله الذي لا يبلغ مدحته القائلون",
        englishText: "Praise is due to Allah whose worth cannot be described by speakers, whose bounties cannot be counted by calculators and whose claim cannot be satisfied by those who attempt to do so. The foremost in religion is the acknowledgement of Him, and the perfection of acknowledging Him is to testify Him.",
        arabicText: "الحمد لله الذي لا يبلغ مدحته القائلون، ولا يحصي نعماءه العادون، ولا يؤدي حقه المجتهدون.",
        subsections: [
            SermonSubsection(
                title: "The Oneness of Allah",
                english: "The perfection of believing in His Oneness is to regard Him Pure, and the perfection of His purity is to deny Him attributes.",
                arabic: "وكمال توحيده الإخلاص له، وكمال الإخلاص له نفي الصفات عنه."
            )
        ],
        sourceURL: URL(string: "https://al-islam.org"),
        wordCount: 2037
    )
}