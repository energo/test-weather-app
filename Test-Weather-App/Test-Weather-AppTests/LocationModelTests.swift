//
//  LocationModelTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//

import XCTest
@testable import Test_Weather_App

final class LocationModelTests: XCTestCase {
    
    func testLocationInitializationWithValidName() {
        let location = Location(name: "London")
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.name, "London")
    }
    
    func testLocationInitializationWithInvalidName() {
        let location = Location(name: "")
        XCTAssertNil(location)
    }
    
    func testLocationTrimsWhitespace() {
        let location = Location(name: "  London  ")
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.name, "London")
    }
    
    func testLocationInitializationWithNumbers() {
        let location = Location(name: "London123")
        XCTAssertNil(location)
    }
    
    func testLocationEquality() {
        let location1 = Location(name: "London")
        let location2 = Location(name: "London")
        XCTAssertEqual(location1, location2)
    }
    
    func testLocationInequality() {
        let location1 = Location(name: "London")
        let location2 = Location(name: "Paris")
        XCTAssertNotEqual(location1, location2)
    }
}
