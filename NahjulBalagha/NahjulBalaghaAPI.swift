import Foundation

protocol SermonProviding: Sendable {
    func listSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonListResponse
    func searchSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonSearchResponse
    func sermon(id: Int) async throws -> Sermon
    func randomSermon() async throws -> Sermon
}

extension SermonProviding {
    func listSermons(query: String, language: SermonLanguage) async throws -> SermonListResponse {
        try await listSermons(query: query, language: language, limit: 100, offset: 0)
    }

    func searchSermons(query: String, language: SermonLanguage) async throws -> SermonSearchResponse {
        try await searchSermons(query: query, language: language, limit: 100, offset: 0)
    }
}

struct NahjulBalaghaAPI: SermonProviding {
    private let baseURL = URL(string: "https://nahj-sermons-api.automatehub.workers.dev")!

    nonisolated init() {}

    func listSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonListResponse {
        var components = components(path: "/sermons")
        var items = [
            URLQueryItem(name: "lang", value: language.rawValue),
            URLQueryItem(name: "sort", value: "id"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            items.append(URLQueryItem(name: "q", value: trimmedQuery))
        }

        components.queryItems = items
        return try await fetch(SermonListResponse.self, from: components)
    }

    func searchSermons(query: String, language: SermonLanguage, limit: Int, offset: Int) async throws -> SermonSearchResponse {
        var components = components(path: "/search")
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "lang", value: language.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        return try await fetch(SermonSearchResponse.self, from: components)
    }

    func sermon(id: Int) async throws -> Sermon {
        let components = components(path: "/sermons/\(id)")
        let response = try await fetch(SermonDetailResponse.self, from: components)
        return response.sermon
    }

    func randomSermon() async throws -> Sermon {
        let components = components(path: "/random")
        let response = try await fetch(RandomSermonResponse.self, from: components)
        return response.sermon
    }

    private func components(path: String) -> URLComponents {
        URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)!
    }

    private func fetch<T: Decodable>(_ type: T.Type, from components: URLComponents) async throws -> T {
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.badResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case badResponse
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The API URL could not be created."
        case .badResponse:
            "The server returned an unexpected response."
        case .decodingFailed(let error):
            "The API response could not be read: \(error.localizedDescription)"
        }
    }
}
