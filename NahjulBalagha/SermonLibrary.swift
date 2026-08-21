import Foundation
import Observation

@MainActor
@Observable
final class SermonLibrary {
    static let fontSizeRange: ClosedRange<Double> = 15...28

    var sermons: [SermonSummary] = []
    var selectedSermon: Sermon?
    // Drives navigation into the reader; cleared when the reader is popped.
    var selectedSummary: SermonSummary?
    // The most recently opened sermon, kept even after the reader is dismissed
    // so the tab bar can offer a "Continue Reading" accessory.
    var currentSummary: SermonSummary?
    var language: SermonLanguage = .english
    var searchText = ""
    var isLoadingList = false
    var isLoadingDetail = false
    var errorMessage: String?
    var totalCount = 0

    // Reader settings, persisted directly so no view-layer mirroring is needed.
    var readerTheme: ReaderTheme = .paper {
        didSet { UserDefaults.standard.set(readerTheme.rawValue, forKey: "readerTheme") }
    }
    var readerFontSize: Double = 19 {
        didSet { UserDefaults.standard.set(readerFontSize, forKey: "readerFontSize") }
    }
    var showsSubsections = true {
        didSet { UserDefaults.standard.set(showsSubsections, forKey: "showsSubsections") }
    }

    // Persisted last-read sermon ID so the user returns to their place
    var lastReadSermonID: Int? {
        didSet {
            if let lastReadSermonID {
                UserDefaults.standard.set(lastReadSermonID, forKey: "lastReadSermonID")
            }
        }
    }

    private let api: any SermonProviding
    private var currentSearchTask: Task<Void, Never>?
    private var loadDetailTask: Task<Void, Never>?

    init(api: any SermonProviding = NahjulBalaghaAPI()) {
        self.api = api

        let defaults = UserDefaults.standard
        if let rawTheme = defaults.string(forKey: "readerTheme"),
           let theme = ReaderTheme(rawValue: rawTheme) {
            readerTheme = theme
        }
        let storedSize = defaults.double(forKey: "readerFontSize")
        if Self.fontSizeRange.contains(storedSize) {
            readerFontSize = storedSize
        }
        if defaults.object(forKey: "showsSubsections") != nil {
            showsSubsections = defaults.bool(forKey: "showsSubsections")
        }
        let storedID = defaults.integer(forKey: "lastReadSermonID")
        lastReadSermonID = storedID > 0 ? storedID : nil
    }

    func loadInitialSermons() async {
        guard sermons.isEmpty else { return }
        await loadSermons()
        restoreLastReadSermon()
    }

    func refreshForCurrentFilters() {
        currentSearchTask?.cancel()
        currentSearchTask = Task {
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            await loadSermons()
        }
    }

    func setLanguage(_ newLanguage: SermonLanguage) {
        guard language != newLanguage else { return }
        language = newLanguage
        // Reload the list (titles/snippets change with language) but don't
        // force a detail reload -- the current sermon already has both
        // English and Arabic text, so the reader swaps instantly.
        currentSearchTask?.cancel()
        currentSearchTask = Task { await loadSermons() }
    }

    /// Loads the detail for a newly selected summary. Called whenever
    /// `selectedSummary` changes, whether from the sidebar or programmatically.
    func showDetail(for summary: SermonSummary) async {
        lastReadSermonID = summary.id
        currentSummary = summary
        guard selectedSermon?.id != summary.id else { return }
        await loadDetail(id: summary.id)
    }

    func increaseReaderFont() {
        readerFontSize = min(Self.fontSizeRange.upperBound, readerFontSize + 1)
    }

    func decreaseReaderFont() {
        readerFontSize = max(Self.fontSizeRange.lowerBound, readerFontSize - 1)
    }

    func loadRandom() async {
        loadDetailTask?.cancel()
        isLoadingDetail = true
        errorMessage = nil
        defer { isLoadingDetail = false }

        do {
            let sermon = try await api.randomSermon()
            selectedSermon = sermon
            // Setting the selection navigates on collapsed (iPhone) layouts
            // and drives showDetail(for:), which records the last-read ID.
            selectedSummary = SermonSummary(
                id: sermon.id,
                title: sermon.title,
                titleArabic: sermon.titleArabic,
                wordCount: sermon.wordCount,
                snippet: nil
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadSermons() async {
        isLoadingList = true
        errorMessage = nil
        defer {
            if !Task.isCancelled {
                isLoadingList = false
            }
        }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if trimmedQuery.isEmpty {
                let response = try await api.listSermons(query: "", language: language)
                sermons = response.sermons
                totalCount = response.total
            } else {
                let response = try await api.searchSermons(query: trimmedQuery, language: language)
                sermons = response.results
                totalCount = response.total
            }
        } catch is CancellationError {
            // Superseded by a newer search; the new task owns the UI state.
        } catch let urlError as URLError where urlError.code == .cancelled {
            // Same as above -- URLSession reports cancellation this way.
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadDetail(id: Int) async {
        loadDetailTask?.cancel()
        isLoadingDetail = true
        errorMessage = nil

        let task = Task { [api] in
            do {
                let sermon = try await api.sermon(id: id)
                guard !Task.isCancelled else { return }
                selectedSermon = sermon
                isLoadingDetail = false
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                isLoadingDetail = false
            }
        }
        loadDetailTask = task
        await task.value
    }

    private func restoreLastReadSermon() {
        guard let lastReadSermonID,
              let match = sermons.first(where: { $0.id == lastReadSermonID }) else { return }
        // Offer the sermon via the "Continue Reading" accessory rather than
        // navigating straight into the reader on launch.
        currentSummary = match
    }
}
