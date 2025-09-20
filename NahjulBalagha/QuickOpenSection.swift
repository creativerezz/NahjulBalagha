import Foundation

public enum AppSection: String, Identifiable {
    case sermons, letters, sayings
    public var id: String { rawValue }
}
