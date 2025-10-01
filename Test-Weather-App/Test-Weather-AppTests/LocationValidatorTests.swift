//
//  LocationValidatorTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//

import XCTest
@testable import Test_Weather_App

final class LocationValidatorTests: XCTestCase {
    
    // MARK: - Valid Locations
    
    func testValidLocation() {
        XCTAssertTrue(LocationValidator.isValid("London"))
        XCTAssertTrue(LocationValidator.isValid("New York"))
        XCTAssertTrue(LocationValidator.isValid("São Paulo"))
        XCTAssertTrue(LocationValidator.isValid("Saint-Petersburg"))
        XCTAssertTrue(LocationValidator.isValid("O'Fallon"))
    }
    
    func testValidLocationWithSpaces() {
        XCTAssertTrue(LocationValidator.isValid("San Francisco"))
        XCTAssertTrue(LocationValidator.isValid("Los Angeles"))
    }
    
    func testValidLocationWithHyphens() {
        XCTAssertTrue(LocationValidator.isValid("Saint-Tropez"))
        XCTAssertTrue(LocationValidator.isValid("Stratford-upon-Avon"))
    }
    
    func testValidLocationWithApostrophes() {
        XCTAssertTrue(LocationValidator.isValid("L'Aquila"))
        XCTAssertTrue(LocationValidator.isValid("O'Hare"))
    }
    
    // MARK: - Invalid Locations
    
    func testEmptyLocation() {
        XCTAssertFalse(LocationValidator.isValid(""))
        XCTAssertFalse(LocationValidator.isValid("   "))
        XCTAssertFalse(LocationValidator.isValid("\n"))
    }
    
    func testLocationTooShort() {
        XCTAssertFalse(LocationValidator.isValid("A"))
    }
    
    func testLocationTooLong() {
        let longLocation = String(repeating: "A", count: 101)
        XCTAssertFalse(LocationValidator.isValid(longLocation))
    }
    
    func testLocationWithNumbers() {
        XCTAssertFalse(LocationValidator.isValid("London123"))
        XCTAssertFalse(LocationValidator.isValid("123"))
    }
    
    func testLocationWithSpecialCharacters() {
        XCTAssertFalse(LocationValidator.isValid("London@"))
        XCTAssertFalse(LocationValidator.isValid("San Francisco!"))
        XCTAssertFalse(LocationValidator.isValid("Paris#"))
        XCTAssertFalse(LocationValidator.isValid("Tokyo$"))
    }
    
    // MARK: - Validation Error Messages
    
    func testValidationErrorForEmpty() {
        let error = LocationValidator.validationError(for: "")
        XCTAssertEqual(error, "Location cannot be empty")
    }
    
    func testValidationErrorForTooShort() {
        let error = LocationValidator.validationError(for: "A")
        XCTAssertEqual(error, "Location must be at least 2 characters")
    }
    
    func testValidationErrorForTooLong() {
        let longLocation = String(repeating: "A", count: 101)
        let error = LocationValidator.validationError(for: longLocation)
        XCTAssertEqual(error, "Location must be less than 100 characters")
    }
    
    func testValidationErrorForInvalidCharacters() {
        let error = LocationValidator.validationError(for: "London123")
        XCTAssertEqual(error, "Location contains invalid characters")
    }
    
    func testNoValidationErrorForValid() {
        let error = LocationValidator.validationError(for: "London")
        XCTAssertNil(error)
    }
    
    // MARK: - Edge Cases
    
    func testLocationWithLeadingAndTrailingSpaces() {
        XCTAssertTrue(LocationValidator.isValid("  London  "))
    }
    
    func testMinimumValidLength() {
        XCTAssertTrue(LocationValidator.isValid("NY"))
    }
    
    func testMaximumValidLength() {
        let maxLocation = String(repeating: "A", count: 100)
        XCTAssertTrue(LocationValidator.isValid(maxLocation))
    }
}
