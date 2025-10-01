//
//  MockURLSession.swift
//  Test-Weather-AppTests
//
//  Created by D C on 01.10.2025.
//

import Foundation
@testable import Test_Weather_App

/// Mock URLSession for testing network layer without real network requests
actor MockURLSession: URLSessionProtocol {
    
    // MARK: - Properties
    
    private var mockResponses: [URL: MockResponse] = [:]
    private var mockErrors: [URL: Error] = [:]
    private var requestCallCount: [URL: Int] = [:]
    
    // MARK: - Mock Response Configuration
    
    struct MockResponse: Sendable {
        let data: Data
        let statusCode: Int
        let headers: [String: String]
        let delay: TimeInterval
        
        init(
            data: Data,
            statusCode: Int = 200,
            headers: [String: String] = ["Content-Type": "application/json"],
            delay: TimeInterval = 0
        ) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
            self.delay = delay
        }
    }
    
    // MARK: - Configuration Methods
    
    func setMockResponse(for url: URL, response: MockResponse) {
        mockResponses[url] = response
    }
    
    func setMockError(for url: URL, error: Error) {
        mockErrors[url] = error
    }
    
    func getCallCount(for url: URL) -> Int {
        return requestCallCount[url] ?? 0
    }
    
    func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        requestCallCount.removeAll()
    }
    
    // MARK: - URLSessionProtocol Implementation
    
    nonisolated func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }
        
        await incrementCallCount(for: url)
        
        // 1) Check for early error
        if let error = await getError(for: url) {
            throw error
        }
        
        // 2) Get mock response
        guard let mockResponse = await getResponse(for: url) else {
            throw NetworkError.noData
        }
        
        // 3) Apply delay if needed
        if mockResponse.delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockResponse.delay * 1_000_000_000))
            // 3b) Re-check for delayed errors
            if let delayedError = await getError(for: url) {
                throw delayedError
            }
        }
        
        // 4) Create HTTPURLResponse
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: mockResponse.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: mockResponse.headers
        )!
        
        return (mockResponse.data, httpResponse)
    }
    
    // MARK: - Private Actor-Isolated Helpers
    
    private func incrementCallCount(for url: URL) {
        requestCallCount[url, default: 0] += 1
    }
    
    private func getError(for url: URL) -> Error? {
        return mockErrors[url]
    }
    
    private func getResponse(for url: URL) -> MockResponse? {
        return mockResponses[url]
    }
}

// MARK: - Convenience Extensions

extension MockURLSession {
    
    func setSuccessResponse(for url: URL, jsonData: Data, statusCode: Int = 200) {
        let response = MockResponse(
            data: jsonData,
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"]
        )
        setMockResponse(for: url, response: response)
    }
    
    func setHTTPError(for url: URL, statusCode: Int, data: Data = Data()) {
        let response = MockResponse(
            data: data,
            statusCode: statusCode,
            headers: [:]
        )
        setMockResponse(for: url, response: response)
    }
    
    func setNetworkError(for url: URL, error: URLError.Code) {
        let urlError = URLError(error)
        setMockError(for: url, error: urlError)
    }
    
    /// Real timeout: returns URLError(.timedOut) - client maps to .timeout
    func setTimeout(for url: URL) {
        setMockError(for: url, error: URLError(.timedOut))
    }
    
    /// Delayed timeout: waits for delay, then throws URLError(.timedOut)
    func setDelayedTimeout(for url: URL, delay: TimeInterval) {
        setMockResponse(for: url, response: MockResponse(data: Data(), statusCode: 200, headers: [:], delay: delay))
        setMockError(for: url, error: URLError(.timedOut))
    }
}

// MARK: - Test Data Helpers

extension MockURLSession {
    
    /// Creates mock JSON for OpenMeteo API
    /// @MainActor required as test class is @MainActor isolated
    @MainActor
    static func createOpenMeteoMockData(
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
    
    /// Creates mock JSON for WeatherAPI
    @MainActor
    static func createWeatherAPIMockData(
        locationName: String = "Paris",
        temperature: Double = 20.0,
        humidity: Int = 70,
        feelsLike: Double = 19.0,
        windKph: Double = 15.0,
        condition: String = "Partly cloudy"
    ) -> Data {
        let location = WeatherAPIResponse.LocationInfo(name: locationName)
        let conditionData = WeatherAPIResponse.CurrentWeather.Condition(text: condition)
        let current = WeatherAPIResponse.CurrentWeather(
            tempC: temperature,
            humidity: humidity,
            feelslikeC: feelsLike,
            windKph: windKph,
            condition: conditionData
        )
        let response = WeatherAPIResponse(location: location, current: current)
        return try! JSONEncoder().encode(response)
    }
    
    static func createInvalidJSONData() -> Data {
        "invalid json data".data(using: .utf8)!
    }
    
    static func createEmptyData() -> Data {
        Data()
    }
}
