//
//  Location.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Validated location model
struct Location: Equatable {
    let name: String
    
    init?(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard LocationValidator.isValid(trimmed) else {
            return nil
        }
        self.name = trimmed
    }
}
