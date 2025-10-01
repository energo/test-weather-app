//
//  LocationValidator.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Validates location input
enum LocationValidator {
    
    static let minimumLength = 2
    static let maximumLength = 100
    
    /// Validates location string
    /// - Parameter location: Location string to validate
    /// - Returns: True if valid, false otherwise
    static func isValid(_ location: String) -> Bool {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        guard !trimmed.isEmpty else {
            return false
        }
        
        // Check minimum length
        guard trimmed.count >= minimumLength else {
            return false
        }
        
        // Check maximum length
        guard trimmed.count <= maximumLength else {
            return false
        }
        
        // Check for invalid characters (only letters, spaces, hyphens, apostrophes)
        let allowedCharacterSet = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-',"))
        
        guard trimmed.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) else {
            return false
        }
        
        return true
    }
    
    /// Returns validation error message for invalid location
    /// - Parameter location: Location string to validate
    /// - Returns: Error message if invalid, nil if valid
    static func validationError(for location: String) -> String? {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Location cannot be empty"
        }
        
        if trimmed.count < minimumLength {
            return "Location must be at least \(minimumLength) characters"
        }
        
        if trimmed.count > maximumLength {
            return "Location must be less than \(maximumLength) characters"
        }
        
        let allowedCharacterSet = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-',"))
        
        if !trimmed.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) {
            return "Location contains invalid characters"
        }
        
        return nil
    }
}
