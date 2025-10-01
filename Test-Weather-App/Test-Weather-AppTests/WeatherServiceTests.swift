//
//  WeatherServiceTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//

import XCTest
@testable import Test_Weather_App

@MainActor
final class WeatherServiceTests: XCTestCase {
    
    var mockNetworkClient: MockNetworkClient!
    var openMeteoService: OpenMeteoService!
    var weatherAPIService: WeatherAPIService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockNetworkClient = MockNetworkClient()
    }
    
    override func tearDown() async throws {
        mockNetworkClient = nil
        openMeteoService = nil
        weatherAPIService = nil
        try await super.tearDown()
    }
    
    // MARK: - Open-Meteo Service Tests
    
    // Note: OpenMeteoService uses CLGeocoder for location lookup before network requests.
    // This means tests will make real geocoding calls to Apple's servers.
    // Use real city names (e.g., "London", "Paris") to ensure geocoding succeeds,
    // allowing us to test the network layer with mocks.
    
    func testOpenMeteoServiceType() {
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        XCTAssertEqual(openMeteoService.serviceType, .openMeteo)
    }
    
    func testOpenMeteoServiceTheme() {
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        XCTAssertTrue(openMeteoService.theme is OpenMeteoTheme)
    }
    
    func testOpenMeteoServiceSuccessfulRequest() async throws {
        // Setup mock response
        mockNetworkClient.mockData = MockNetworkClient.mockOpenMeteoData(
            temperature: 22.5,
            humidity: 65,
            feelsLike: 21.0,
            windSpeed: 5.5,
            weatherCode: 1
        )
        
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        let location = Location(name: "London")!
        
        let weatherData = try await openMeteoService.fetchWeather(for: location)
        
        XCTAssertEqual(weatherData.location, "London")
        XCTAssertTrue(weatherData.serviceName.contains("Open-Meteo"))
        XCTAssertEqual(weatherData.temperature, 22.5, accuracy: 0.1)
        XCTAssertEqual(weatherData.humidity, 65)
        XCTAssertEqual(weatherData.feelsLike, 21.0, accuracy: 0.1)
        XCTAssertEqual(weatherData.windSpeed, 5.5, accuracy: 0.1)
        XCTAssertEqual(mockNetworkClient.requestCount, 1)
    }
    
    func testOpenMeteoServiceNetworkError() async {
        // Setup mock error
        mockNetworkClient.mockError = NetworkError.httpError(statusCode: 500)
        
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        
        // Use a real city name so geocoding succeeds, then network error will be thrown
        let location = Location(name: "London")!
        
        do {
            _ = try await openMeteoService.fetchWeather(for: location)
            XCTFail("Expected error to be thrown")
        } catch {
            // Should catch the network error after successful geocoding
            XCTAssertTrue(error is NetworkError)
            if let networkError = error as? NetworkError,
               case .httpError(let statusCode) = networkError {
                XCTAssertEqual(statusCode, 500)
            }
            XCTAssertEqual(mockNetworkClient.requestCount, 1)
        }
    }
    
    // MARK: - WeatherAPI Service Tests
    
    func testWeatherAPIServiceType() {
        weatherAPIService = WeatherAPIService(networkClient: mockNetworkClient)
        XCTAssertEqual(weatherAPIService.serviceType, .weatherAPI)
    }
    
    func testWeatherAPIServiceTheme() {
        weatherAPIService = WeatherAPIService(networkClient: mockNetworkClient)
        XCTAssertTrue(weatherAPIService.theme is WeatherAPITheme)
    }
    
    func testWeatherAPIServiceSuccessfulRequest() async throws {
        // Setup mock response
        mockNetworkClient.mockData = MockNetworkClient.mockWeatherAPIData(
            locationName: "Paris",
            temperature: 20.0,
            humidity: 70,
            feelsLike: 19.0,
            windKph: 15.0,
            condition: "Partly cloudy"
        )
        
        weatherAPIService = WeatherAPIService(networkClient: mockNetworkClient)
        let location = Location(name: "Paris")!
        
        let weatherData = try await weatherAPIService.fetchWeather(for: location)
        
        XCTAssertEqual(weatherData.location, "Paris")
        XCTAssertTrue(weatherData.serviceName.contains("WeatherAPI"))
        XCTAssertEqual(weatherData.temperature, 20.0, accuracy: 0.1)
        XCTAssertEqual(weatherData.humidity, 70)
        XCTAssertEqual(weatherData.feelsLike, 19.0, accuracy: 0.1)
        XCTAssertEqual(weatherData.weatherDescription, "Partly cloudy")
        XCTAssertEqual(mockNetworkClient.requestCount, 1)
    }
    
    func testWeatherAPIServiceNetworkError() async {
        // Setup mock error
        mockNetworkClient.mockError = NetworkError.invalidResponse
        
        weatherAPIService = WeatherAPIService(networkClient: mockNetworkClient)
        let location = Location(name: "InvalidCity")!
        
        do {
            _ = try await weatherAPIService.fetchWeather(for: location)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
            XCTAssertEqual(mockNetworkClient.requestCount, 1)
        }
    }
    
    // MARK: - Service Comparison Tests
    
    func testServiceInterchangeability() async throws {
        // Test that both services can be used interchangeably
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        weatherAPIService = WeatherAPIService(networkClient: mockNetworkClient)
        
        let services: [WeatherServiceProtocol] = [openMeteoService, weatherAPIService]
        
        for service in services {
            XCTAssertNotNil(service.serviceType)
            XCTAssertNotNil(service.theme)
        }
    }
    
    // MARK: - Performance Tests
    
    func testServicePerformance() async throws {
        let delayTime: TimeInterval = 0.1
        mockNetworkClient.mockDelay = delayTime
        mockNetworkClient.mockData = MockNetworkClient.mockOpenMeteoData()
        
        openMeteoService = OpenMeteoService(networkClient: mockNetworkClient)
        let location = Location(name: "London")!
        
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await openMeteoService.fetchWeather(for: location)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should take at least the delay time
        XCTAssertGreaterThanOrEqual(timeElapsed, delayTime)
        XCTAssertEqual(mockNetworkClient.requestCount, 1)
    }
}
