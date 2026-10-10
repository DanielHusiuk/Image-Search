//
//  SearchManager.swift
//  Image Search
//
//  Created by Daniel Husiuk on 08.10.2026.
//

import Foundation

enum SearchValidationResult {
    case success(String)
    case empty
    case invalid
}

enum SearchManager {
    
    static func validate(_ text: String) -> SearchValidationResult {
        let searchString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !searchString.isEmpty else {
            return .empty
        }
        
        let isEnglishText = searchString.allSatisfy { character in
            character.isASCII &&
            (character.isLetter || character.isNumber || character == " ")
        }
        
        guard searchString.count <= 100,
              isEnglishText else {
            return .invalid
        }
        
        return .success(searchString)
    }
}
