//
//  SearchResult.swift
//  NahjulBalagha
//
//  Created by AI Assistant on 1/1/26.
//

import Foundation

/// Unified search result type that can represent any content type
enum SearchResult: Identifiable {
    case sermon(Sermon)
    case letter(Letter)
    case saying(Saying)
    
    var id: String {
        switch self {
        case .sermon(let sermon):
            return "sermon-\(sermon.id)"
        case .letter(let letter):
            return "letter-\(letter.id)"
        case .saying(let saying):
            return "saying-\(saying.id)"
        }
    }
    
    /// Display title for the search result
    var displayTitle: String {
        switch self {
        case .sermon(let sermon):
            return "Sermon \(sermon.number): \(sermon.title)"
        case .letter(let letter):
            return "Letter \(letter.number): \(letter.title)"
        case .saying(let saying):
            return "Saying \(saying.number): \(saying.topic)"
        }
    }
    
    /// Excerpt or preview text
    var excerpt: String {
        switch self {
        case .sermon(let sermon):
            return sermon.excerpt
        case .letter(let letter):
            return letter.excerpt
        case .saying(let saying):
            return saying.text
        }
    }
    
    /// Content type label
    var contentType: String {
        switch self {
        case .sermon:
            return "Sermon"
        case .letter:
            return "Letter"
        case .saying:
            return "Saying"
        }
    }
    
    /// Category name
    var categoryName: String {
        switch self {
        case .sermon(let sermon):
            return sermon.category.rawValue
        case .letter(let letter):
            return letter.category.rawValue
        case .saying(let saying):
            return saying.category.rawValue
        }
    }
}
