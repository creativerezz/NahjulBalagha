import Foundation

enum AppSection: String, Identifiable {
    case sermons
    case letters
    case sayings

    var id: String { rawValue }
}
