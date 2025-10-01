//
//  MockNetworkClient.swift
//  Test-Weather-AppTests
//
//  Created by D C on 01.10.2025.
//

import Foundation
@testable import Test_Weather_App

/// Mock network client for testing
/// Allows controlling responses and errors without real network calls
@MainActor
final class MockNetworkClient: NetworkClientProtocol {
    
    // MARK: - Configuration
    
    /// Mock response data to return
    var mockData: Data?
    
    /// Mock error to throw
    var mockError: Error?
    
    /// Delay before returning response (for testing timeouts)
    var mockDelay: TimeInterval = 0
    
    /// Number of requests made
    private(set) var requestCount = 0
    
    /// Last request made
    private(set) var lastRequest: Any?
    
    init(mockData: Data? = nil, mockError: Error? = nil, mockDelay: TimeInterval = 0) {
        self.mockData = mockData
        self.mockError = mockError
        self.mockDelay = mockDelay
    }
    
    // MARK: - NetworkClientProtocol
    
    func request<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        return try await self.request(request, retryConfiguration: RetryConfiguration.none)
    }
    
    func request<T: NetworkRequest>(
        _ request: T,
        retryConfiguration: RetryConfiguration
    ) async throws -> T.Response {
        requestCount += 1
        lastRequest = request
        
        // Simulate delay if configured
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        // Throw error if configured
        if let error = mockError {
            throw error
        }
        
        // Return mock data if configured
        guard let data = mockData else {
            throw NetworkError.noData
        }
        
        // Decode the mock data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.Response.self, from: data)
    }
    
    // MARK: - Mock Data Helpers
    
    /// Creates mock Open-Meteo response data
    static func mockOpenMeteoData(
        temperature: Double = 22.5,
        humidity: Int = 65,
        feelsLike: Double = 21.0,
        windSpeed: Double = 5.5,
        weatherCode: Int = 1
    ) -> Data {
        let response = OpenMeteoResponse(
            latitude: 51.5074,
            longitude: -0.1278,
            timezone: "Europe/London",
            current: OpenMeteoResponse.CurrentWeather(
                time: "2025-10-01T12:00",
                temperature2m: temperature,
                relativeHumidity2m: humidity,
                apparentTemperature: feelsLike,
                weatherCode: weatherCode,
                windSpeed10m: windSpeed
            )
        )
        
        return try! JSONEncoder().encode(response)
    }
    
    /// Creates mock WeatherAPI response data
    static func mockWeatherAPIData(
        locationName: String = "Paris",
        temperature: Double = 20.0,
        humidity: Int = 70,
        feelsLike: Double = 19.0,
        windKph: Double = 15.0,
        condition: String = "Partly cloudy"
    ) -> Data {
        let location = WeatherAPIResponse.LocationInfo(
            name: locationName
        )
        
        let conditionData = WeatherAPIResponse.CurrentWeather.Condition(
            text: condition
        )
        
        let current = WeatherAPIResponse.CurrentWeather(
            tempC: temperature,
            humidity: humidity,
            feelslikeC: feelsLike,
            windKph: windKph,
            condition: conditionData
        )
        
        let response = WeatherAPIResponse(
            location: location,
            current: current
        )
        
        return try! JSONEncoder().encode(response)
    }
    
    /// Resets the mock state
    func reset() {
        mockData = nil
        mockError = nil
        mockDelay = 0
        requestCount = 0
        lastRequest = nil
    }
}
