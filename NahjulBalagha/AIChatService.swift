import Foundation
import SwiftUI
import Combine
#if canImport(FoundationModels)
import FoundationModels

@Generable(description: "Action request from the assistant")
struct NBGeneratedAction {
    var command: String
    var bool: Bool?
}

@Generable(description: "Nahj al-Balagha assistant turn")
struct NBGeneratedTurn {
    // A reply string to show to the user.
    var reply: String

    // Optional action the model can produce
    var action: NBGeneratedAction?

    // Optional search results list
    @Guide(description: "Short list of relevant results", .count(3))
    var searchResults: [String]?
}
#endif

// MARK: - AI Provider Configuration
enum AIProvider: String, CaseIterable, Identifiable {
    case foundationModels = "foundation_models"
    case openRouter = "openrouter"
    case localStub = "local_stub"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .foundationModels: return "Apple Intelligence"
        case .openRouter: return "OpenRouter"
        case .localStub: return "Local Stub"
        }
    }
    
    var description: String {
        switch self {
        case .foundationModels: return "On-device Apple Intelligence models"
        case .openRouter: return "Cloud-based LLMs via OpenRouter"
        case .localStub: return "Simple fallback for testing"
        }
    }
    
    var icon: String {
        switch self {
        case .foundationModels: return "sparkles"
        case .openRouter: return "cloud.fill"
        case .localStub: return "hammer.fill"
        }
    }
}

struct OpenRouterConfig {
    static var apiKey: String {
        // Try to get from UserDefaults first, fallback to empty string
        UserDefaults.standard.string(forKey: "openrouter_api_key") ?? ""
    }
    
    static func setApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openrouter_api_key")
    }
    
    static let baseURL = "https://openrouter.ai/api/v1"
    
    // Popular models available on OpenRouter
    static let availableModels = [
        "openai/gpt-4o-mini",
        "openai/gpt-4o",
        "anthropic/claude-3.5-sonnet",
        "anthropic/claude-3-haiku",
        "meta-llama/llama-3.1-8b-instruct:free",
        "google/gemini-flash-1.5"
    ]
}

// MARK: - OpenRouter Response Models
struct OpenRouterResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let message: Message
        let finish_reason: String?
    }
    
    struct Message: Codable {
        let content: String
        let role: String
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
    }
}

// MARK: - Availability (local shim)
/// Minimal availability type used by AIChatService.
/// If a shared project-wide Availability exists, you can remove this shim
/// and import/use that type instead.
enum Availability: Equatable {
    case available
    case unavailable(reason: String? = nil)
}

// MARK: - AssistantTurn model used by ContentView
public struct AssistantTurn {
    public struct Action: Equatable {
        public var command: String
        public var bool: Bool?
        public init(command: String, bool: Bool? = nil) {
            self.command = command
            self.bool = bool
        }
    }

    public struct PartialTurn: Equatable {
        public var reply: String?
        public var searchResults: [String]? // Used to present a sheet in ContentView
        public var action: Action?          // Used to trigger quick opens or theme changes
        public init(reply: String? = nil, searchResults: [String]? = nil, action: Action? = nil) {
            self.reply = reply
            self.searchResults = searchResults
            self.action = action
        }
    }
}

// MARK: - AIChatService
/// An enhanced AI chat service that supports multiple providers:
/// - Foundation Models (Apple Intelligence) when available
/// - OpenRouter for cloud-based LLMs
/// - Local stub as fallback
@available(iOS 26.0, *)
@MainActor
final class AIChatService: ObservableObject {
    // Public state observed by UI
    @Published var availability: Availability = .available
    @Published var currentProvider: AIProvider
    @Published var selectedModel: String
    
    var isAvailable: Bool {
        if case .available = availability { return true }
        return false
    }

    // Tool handlers that ContentView configures so the model can trigger UI actions
    private var openHandler: ((AppSection) -> Void)?
    private var setDarkModeHandler: ((Bool) -> Void)?

    /// Configure tool callbacks so a response can control navigation or theme.
    func makeToolEnabledSession(openHandler: @escaping (AppSection) -> Void,
                                setDarkMode: @escaping (Bool) -> Void) {
        self.openHandler = openHandler
        self.setDarkModeHandler = setDarkMode
    }

    #if canImport(FoundationModels)
    private let systemModel = SystemLanguageModel.default
    #endif

    init() {
        // Load saved provider preference or default to Foundation Models
        let savedProvider = UserDefaults.standard.string(forKey: "ai_provider") ?? AIProvider.foundationModels.rawValue
        self.currentProvider = AIProvider(rawValue: savedProvider) ?? .foundationModels
        
        // Load saved model preference
        self.selectedModel = UserDefaults.standard.string(forKey: "selected_model") ?? OpenRouterConfig.availableModels[0]
        
        updateAvailability()
    }
    
    func setProvider(_ provider: AIProvider) {
        currentProvider = provider
        UserDefaults.standard.set(provider.rawValue, forKey: "ai_provider")
        updateAvailability()
    }
    
    func setModel(_ model: String) {
        selectedModel = model
        UserDefaults.standard.set(model, forKey: "selected_model")
    }
    
    func updateAvailability() {
        switch currentProvider {
        case .foundationModels:
            #if canImport(FoundationModels)
            switch systemModel.availability {
            case .available:
                availability = .available
            case .unavailable(.deviceNotEligible):
                availability = .unavailable(reason: "Device not eligible for Apple Intelligence.")
            case .unavailable(.appleIntelligenceNotEnabled):
                availability = .unavailable(reason: "Enable Apple Intelligence in Settings.")
            case .unavailable(.modelNotReady):
                availability = .unavailable(reason: "Model is downloading or not ready.")
            case .unavailable(let other):
                availability = .unavailable(reason: "Model unavailable: \(other)")
            }
            #else
            availability = .unavailable(reason: "Foundation Models not available on this platform.")
            #endif
            
        case .openRouter:
            if OpenRouterConfig.apiKey.isEmpty {
                availability = .unavailable(reason: "OpenRouter API key required. Set it in Settings.")
            } else {
                availability = .available
            }
            
        case .localStub:
            availability = .available
        }
    }

    /// Streams partial assistant output for a given user prompt.
    /// Routes to the appropriate provider based on current selection.
    func streamTurn(for prompt: String) -> AsyncThrowingStream<AssistantTurn.PartialTurn, Error> {
        switch currentProvider {
        case .foundationModels:
            #if canImport(FoundationModels)
            if case .available = availability {
                return streamWithFoundationModels(prompt: prompt)
            } else {
                return stubStream(for: prompt)
            }
            #else
            return stubStream(for: prompt)
            #endif
            
        case .openRouter:
            if case .available = availability {
                return streamWithOpenRouter(prompt: prompt)
            } else {
                return stubStream(for: prompt)
            }
            
        case .localStub:
            return stubStream(for: prompt)
        }
    }

    // MARK: - Foundation Models integration
    #if canImport(FoundationModels)

    // Helpers to coerce partially generated snapshot values into concrete Swift types
    private func toString(_ value: String.PartiallyGenerated?) -> String? {
        value.map { "\($0)" }
    }

    private func toStringArray(_ value: [String].PartiallyGenerated?) -> [String]? {
        value?.map { "\($0)" }
    }

    private func toAction(_ value: NBGeneratedAction.PartiallyGenerated?) -> AssistantTurn.Action? {
        guard let value else { return nil }
        // Require a concrete command to construct an action
        guard let command = value.command.map({ "\($0)" }) else { return nil }
        return AssistantTurn.Action(command: command, bool: value.bool)
    }

    private func streamWithFoundationModels(prompt: String) -> AsyncThrowingStream<AssistantTurn.PartialTurn, Error> {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                do {
                    let instructions = """
                    You are a helpful assistant for a Nahj al-Balagha app.
                    - Prefer concise responses.
                    - When the user asks to open Sermons, Letters, or Sayings, set action.command to one of: openSermons, openLetters, openSayings.
                    - When the user asks for dark or light mode, set action.command = \"setDarkMode\" and action.bool accordingly.
                    - For general queries, provide up to 3 short searchResults.
                    """

                    // Create a session; reuse for multi-turn if you maintain context elsewhere
                    let session = LanguageModelSession(instructions: instructions)

                    // Stream partially generated snapshots of our structured type
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: NBGeneratedTurn.self
                    )

                    for try await partial in stream {
                        // Convert partially generated snapshot values using helpers
                        let replyText = toString(partial.content.reply)
                        let search = toStringArray(partial.content.searchResults)
                        let action = toAction(partial.content.action)

                        continuation.yield(
                            AssistantTurn.PartialTurn(
                                reply: replyText,
                                searchResults: search,
                                action: action
                            )
                        )

                        // Trigger side effects immediately when present
                        if let action {
                            switch action.command {
                            case "openSermons": self.openHandler?(.sermons)
                            case "openLetters": self.openHandler?(.letters)
                            case "openSayings": self.openHandler?(.sayings)
                            case "setDarkMode":
                                if let toDark = action.bool { self.setDarkModeHandler?(toDark) }
                            default: break
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    #endif

    // MARK: - OpenRouter integration
    private func streamWithOpenRouter(prompt: String) -> AsyncThrowingStream<AssistantTurn.PartialTurn, Error> {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    // Initial thinking message
                    continuation.yield(AssistantTurn.PartialTurn(reply: "Thinking..."))
                    
                    let url = URL(string: "\(OpenRouterConfig.baseURL)/chat/completions")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(OpenRouterConfig.apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("NahjulBalaghaApp/1.0", forHTTPHeaderField: "User-Agent")
                    
                    let systemMessage = """
                    You are a helpful assistant for a Nahj al-Balagha app. You help users search and navigate content.
                    
                    Instructions:
                    - Keep responses concise and helpful
                    - When users ask to open sections (sermons, letters, sayings), acknowledge and guide them
                    - When users ask about themes or settings, provide appropriate guidance
                    - For content searches, suggest relevant terms or topics from Islamic literature
                    
                    Respond in a structured JSON format:
                    {
                        "reply": "your response text",
                        "action": {"command": "action_name", "bool": true/false} (optional),
                        "searchResults": ["result1", "result2", "result3"] (optional)
                    }
                    
                    Action commands:
                    - "openSermons" / "openLetters" / "openSayings" for navigation
                    - "setDarkMode" with bool true/false for theme changes
                    """
                    
                    let body: [String: Any] = [
                        "model": selectedModel,
                        "messages": [
                            ["role": "system", "content": systemMessage],
                            ["role": "user", "content": prompt]
                        ],
                        "max_tokens": 500,
                        "temperature": 0.7
                    ]
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    // Check for HTTP errors
                    if let httpResponse = response as? HTTPURLResponse {
                        guard 200...299 ~= httpResponse.statusCode else {
                            let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"])
                        }
                    }
                    
                    let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
                    
                    guard let firstChoice = openRouterResponse.choices.first else {
                        throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "No response choices"])
                    }
                    
                    let content = firstChoice.message.content
                    
                    // Try to parse as structured JSON first
                    if let jsonData = content.data(using: .utf8),
                       let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        
                        let reply = parsed["reply"] as? String
                        var action: AssistantTurn.Action? = nil
                        var searchResults: [String]? = nil
                        
                        // Parse action
                        if let actionDict = parsed["action"] as? [String: Any],
                           let command = actionDict["command"] as? String {
                            let bool = actionDict["bool"] as? Bool
                            action = AssistantTurn.Action(command: command, bool: bool)
                        }
                        
                        // Parse search results
                        if let results = parsed["searchResults"] as? [String] {
                            searchResults = results
                        }
                        
                        // Yield structured response
                        continuation.yield(AssistantTurn.PartialTurn(
                            reply: reply,
                            searchResults: searchResults,
                            action: action
                        ))
                        
                        // Trigger side effects
                        if let action {
                            switch action.command {
                            case "openSermons": self.openHandler?(.sermons)
                            case "openLetters": self.openHandler?(.letters)
                            case "openSayings": self.openHandler?(.sayings)
                            case "setDarkMode":
                                if let toDark = action.bool { self.setDarkModeHandler?(toDark) }
                            default: break
                            }
                        }
                        
                    } else {
                        // Fallback: treat as plain text and try to infer actions
                        let lower = content.lowercased()
                        var inferredAction: AssistantTurn.Action? = nil
                        
                        if lower.contains("open sermons") || lower.contains("sermons") {
                            inferredAction = AssistantTurn.Action(command: "openSermons")
                            self.openHandler?(.sermons)
                        } else if lower.contains("open letters") || lower.contains("letters") {
                            inferredAction = AssistantTurn.Action(command: "openLetters")
                            self.openHandler?(.letters)
                        } else if lower.contains("open sayings") || lower.contains("sayings") {
                            inferredAction = AssistantTurn.Action(command: "openSayings")
                            self.openHandler?(.sayings)
                        } else if lower.contains("dark mode") {
                            inferredAction = AssistantTurn.Action(command: "setDarkMode", bool: true)
                            self.setDarkModeHandler?(true)
                        } else if lower.contains("light mode") {
                            inferredAction = AssistantTurn.Action(command: "setDarkMode", bool: false)
                            self.setDarkModeHandler?(false)
                        }
                        
                        continuation.yield(AssistantTurn.PartialTurn(
                            reply: content,
                            action: inferredAction
                        ))
                    }
                    
                    continuation.finish()
                    
                } catch {
                    // Provide error message to user
                    continuation.yield(AssistantTurn.PartialTurn(
                        reply: "Sorry, I encountered an error: \(error.localizedDescription)"
                    ))
                    continuation.finish()
                }
            }
        }
    }

    // MARK: - Local deterministic stub (fallback)
    private func stubStream(for prompt: String) -> AsyncThrowingStream<AssistantTurn.PartialTurn, Error> {
        AsyncThrowingStream { continuation in
            // Simple routing based on keywords to demonstrate structured outputs
            let lower = prompt.lowercased()

            // Simulate streaming a textual reply first
            Task { [weak self] in
                guard let self else { return }
                do {
                    // First partial reply
                    try await Task.sleep(nanoseconds: 250_000_000)
                    continuation.yield(AssistantTurn.PartialTurn(reply: "Thinking…"))

                    // Second partial depends on intent
                    try await Task.sleep(nanoseconds: 350_000_000)

                    if lower.contains("open sermons") || lower.contains("go to sermons") {
                        // Provide both a reply and an action
                        continuation.yield(AssistantTurn.PartialTurn(reply: "Opening Sermons…",
                                                                    action: .init(command: "openSermons")))
                        self.openHandler?(.sermons)
                    } else if lower.contains("open letters") || lower.contains("go to letters") {
                        continuation.yield(AssistantTurn.PartialTurn(reply: "Opening Letters…",
                                                                    action: .init(command: "openLetters")))
                        self.openHandler?(.letters)
                    } else if lower.contains("open sayings") || lower.contains("go to sayings") {
                        continuation.yield(AssistantTurn.PartialTurn(reply: "Opening Sayings…",
                                                                    action: .init(command: "openSayings")))
                        self.openHandler?(.sayings)
                    } else if lower.contains("dark mode") || lower.contains("light mode") || lower.contains("theme") {
                        let toDark = lower.contains("dark") && !lower.contains("light")
                        continuation.yield(AssistantTurn.PartialTurn(reply: toDark ? "Switching to dark mode." : "Switching to light mode.",
                                                                    action: .init(command: "setDarkMode", bool: toDark)))
                        self.setDarkModeHandler?(toDark)
                    } else {
                        // Default: pretend we did a search and return a few demo results
                        let demo = [
                            "Sermon 1: The Nature of Wisdom",
                            "Letter 1: To Malik al-Ashtar",
                            "Saying 1: On Knowledge and Action"
                        ]
                        continuation.yield(AssistantTurn.PartialTurn(reply: "Here are some results I found.",
                                                                    searchResults: demo))
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

