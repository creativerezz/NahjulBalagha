import Foundation

struct SermonSummary: Identifiable, Decodable, Hashable {
    let id: Int
    let title: String
    let titleArabic: String
    let wordCount: Int
    let snippet: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case titleArabic = "title_arabic"
        case wordCount = "word_count"
        case snippet
    }

    init(id: Int, title: String, titleArabic: String, wordCount: Int, snippet: String?) {
        self.id = id
        self.title = title
        self.titleArabic = titleArabic
        self.wordCount = wordCount
        self.snippet = snippet
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        titleArabic = try container.decodeIfPresent(String.self, forKey: .titleArabic) ?? ""
        wordCount = try container.decodeIfPresent(Int.self, forKey: .wordCount) ?? 0
        snippet = try container.decodeIfPresent(String.self, forKey: .snippet)
    }

    var cleanSnippet: String? {
        snippet?
            .replacingOccurrences(of: "<mark>", with: "")
            .replacingOccurrences(of: "</mark>", with: "")
    }

    var estimatedReadMinutes: Int {
        max(1, Int(ceil(Double(wordCount) / 180.0)))
    }
}

struct Sermon: Identifiable, Decodable, Hashable {
    let id: Int
    let title: String
    let titleArabic: String
    let englishText: String
    let arabicText: String
    let subsections: [SermonSubsection]
    let sourceURL: URL?
    let wordCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case titleArabic = "title_arabic"
        case englishText = "english_text"
        case arabicText = "arabic_text"
        case subsections
        case sourceURL = "source_url"
        case wordCount = "word_count"
    }

    init(
        id: Int,
        title: String,
        titleArabic: String,
        englishText: String,
        arabicText: String,
        subsections: [SermonSubsection],
        sourceURL: URL?,
        wordCount: Int
    ) {
        self.id = id
        self.title = title
        self.titleArabic = titleArabic
        self.englishText = englishText
        self.arabicText = arabicText
        self.subsections = subsections
        self.sourceURL = sourceURL
        self.wordCount = wordCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        titleArabic = try container.decodeIfPresent(String.self, forKey: .titleArabic) ?? ""
        englishText = try container.decode(String.self, forKey: .englishText)
        arabicText = try container.decodeIfPresent(String.self, forKey: .arabicText) ?? ""
        if let sourceURLString = try container.decodeIfPresent(String.self, forKey: .sourceURL) {
            sourceURL = URL(string: sourceURLString)
        } else {
            sourceURL = nil
        }
        wordCount = try container.decode(Int.self, forKey: .wordCount)

        if let subsectionString = try container.decodeIfPresent(String.self, forKey: .subsections),
           let data = subsectionString.data(using: .utf8),
           let raw = try? JSONDecoder().decode([RawSubsection].self, from: data) {
            // Positional IDs keep subsection identity stable across re-decodes
            // of the same sermon, unlike a per-decode UUID.
            subsections = raw.enumerated().map { index, item in
                SermonSubsection(
                    id: index,
                    title: item.title ?? "Section",
                    english: item.english ?? "",
                    arabic: item.arabic ?? ""
                )
            }
        } else {
            subsections = []
        }
    }

    var estimatedReadMinutes: Int {
        max(1, Int(ceil(Double(wordCount) / 180.0)))
    }
}

struct SermonSubsection: Identifiable, Hashable {
    let id: Int
    let title: String
    let english: String
    let arabic: String

    init(id: Int = 0, title: String, english: String, arabic: String) {
        self.id = id
        self.title = title
        self.english = english
        self.arabic = arabic
    }
}

private struct RawSubsection: Decodable {
    let title: String?
    let english: String?
    let arabic: String?
}

struct SermonListResponse: Decodable {
    let total: Int
    let limit: Int
    let offset: Int
    let count: Int
    let sermons: [SermonSummary]
}

struct SermonSearchResponse: Decodable {
    let query: String
    let lang: String
    let total: Int
    let limit: Int
    let offset: Int
    let results: [SermonSummary]
}

struct SermonDetailResponse: Decodable {
    let sermon: Sermon
}

struct RandomSermonResponse: Decodable {
    let sermon: Sermon
}

enum SermonLanguage: String, CaseIterable, Identifiable, Equatable {
    case english = "en"
    case arabic = "ar"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .arabic: "Arabic"
        }
    }

    var symbolName: String {
        switch self {
        case .english: "textformat"
        case .arabic: "textformat.rtl"
        }
    }
}

enum ReaderTheme: String, CaseIterable, Identifiable, Equatable {
    case paper
    case sepia
    case night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paper: "Paper"
        case .sepia: "Sepia"
        case .night: "Night"
        }
    }

    var symbolName: String {
        switch self {
        case .paper: "doc.text"
        case .sepia: "sun.max"
        case .night: "moon"
        }
    }
}