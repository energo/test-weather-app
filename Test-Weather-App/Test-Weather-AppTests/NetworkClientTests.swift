//
//  NetworkClientTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//

import Testing
import Foundation
@testable import Test_Weather_App

@MainActor
@Suite("NetworkClient Tests")
struct NetworkClientTests {
    
    // MARK: - Initialization
    
    @Test("NetworkClient can be initialized with default configuration")
    func networkClientInitialization() async throws {
        let mockSession = MockURLSession()
        let networkClient: NetworkClient? = NetworkClient(session: mockSession)
        #expect(networkClient != nil)
    }
    
    @Test("NetworkClient can be initialized with custom RetryConfiguration")
    func networkClientWithCustomConfiguration() async throws {
        let mockSession = MockURLSession()
        let customConfig = RetryConfiguration.aggressive
        let client: NetworkClient? = NetworkClient(session: mockSession, defaultRetryConfiguration: customConfig)
        #expect(client != nil)
    }

    // MARK: - Success
    
    @Test("Successful OpenMeteo forecast request returns correct weather data")
    func successfulOpenMeteoRequest() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let mockData = MockURLSession.createOpenMeteoMockData()
        
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setSuccessResponse(for: url, jsonData: mockData)
        
        let response = try await networkClient.request(request)
        
        #expect(abs(response.current.temperature2m - 22.5) < 0.1)
        #expect(response.current.relativeHumidity2m == 65)
        
        let callCount = await mockSession.getCallCount(for: url)
        #expect(callCount == 1)
    }
    
    @Test("Successful WeatherAPI request returns correct weather data")
    func successfulWeatherAPIRequest() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let mockData = MockURLSession.createWeatherAPIMockData()
        
        let request = WeatherAPICurrentRequest(location: "Paris", apiKey: "test-key")
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setSuccessResponse(for: url, jsonData: mockData)
        
        let response = try await networkClient.request(request)
        
        #expect(abs(response.current.tempC - 20.0) < 0.1)
        #expect(response.current.humidity == 70)
        
        let callCount = await mockSession.getCallCount(for: url)
        #expect(callCount == 1)
    }

    // MARK: - HTTP Errors
    
    @Test("HTTP 400 error is correctly handled and reported")
    func httpError400() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setHTTPError(for: url, statusCode: 400)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }
    
    @Test("HTTP 500 error triggers retry logic and fails after max retries")
    func httpError500() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setHTTPError(for: url, statusCode: 500)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }

    // MARK: - Decoding Errors
    
    @Test("Invalid JSON data triggers decoding error")
    func decodingErrorWithInvalidJSON() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        
        let invalidData = MockURLSession.createInvalidJSONData()
        await mockSession.setSuccessResponse(for: url, jsonData: invalidData)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }
    
    @Test("Empty data triggers decoding error")
    func decodingErrorWithEmptyData() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        
        let emptyData = MockURLSession.createEmptyData()
        await mockSession.setSuccessResponse(for: url, jsonData: emptyData)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }

    // MARK: - Network Errors
    
    @Test("Network unavailable error is correctly handled")
    func networkUnavailableError() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setNetworkError(for: url, error: .notConnectedToInternet)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }
    
    @Test("Timeout error is correctly handled")
    func timeoutError() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setTimeout(for: url)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
    }

    // MARK: - Retry Logic
    
    @Test("Retry logic is triggered for transient HTTP 500 errors")
    func retryLogicWithTransientError() async throws {
        let mockSession = MockURLSession()
        let networkClient = NetworkClient(session: mockSession)
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setHTTPError(for: url, statusCode: 500)
        
        await #expect(throws: NetworkError.self) {
            try await networkClient.request(request)
        }
        
        // Verify retries were attempted
        let callCount = await mockSession.getCallCount(for: url)
        #expect(callCount > 1, "Expected retries but got \(callCount) call(s)")
    }
    
    @Test("Custom retry configuration is respected")
    func retryConfigurationCustom() async throws {
        let mockSession = MockURLSession()
        let customConfig = RetryConfiguration(
            maxRetries: 2,
            baseDelay: 0.1,
            maxDelay: 1.0,
            backoffMultiplier: 2.0,
            retryableStatusCodes: [500],
            retryableErrors: [.timedOut]
        )
        let client = NetworkClient(session: mockSession, defaultRetryConfiguration: customConfig)
        
        let request = OpenMeteoForecastRequest(latitude: 51.5074, longitude: -0.1278)
        guard let url = request.endpoint.url else {
            Issue.record("Failed to create URL from endpoint")
            return
        }
        await mockSession.setHTTPError(for: url, statusCode: 500)
        
        await #expect(throws: NetworkError.self) {
            try await client.request(request)
        }
        
        let callCount = await mockSession.getCallCount(for: url)
        #expect(callCount == 3, "Expected 1 initial + 2 retries, got \(callCount)")
    }

    // MARK: - Configuration Validation
    
    @Test("Default RetryConfiguration has expected values")
    func retryConfigurationDefault() {
        let config = RetryConfiguration.default
        #expect(config.maxRetries == 3)
        #expect(config.baseDelay == 1.0)
        #expect(config.maxDelay == 30.0)
        #expect(config.backoffMultiplier == 2.0)
    }
    
    @Test("Aggressive RetryConfiguration has expected values")
    func retryConfigurationAggressive() {
        let config = RetryConfiguration.aggressive
        #expect(config.maxRetries == 5)
        #expect(config.baseDelay == 0.5)
        #expect(config.maxDelay == 60.0)
        #expect(config.backoffMultiplier == 1.5)
    }
    
    @Test("None RetryConfiguration disables retries")
    func retryConfigurationNone() {
        let config = RetryConfiguration.none
        #expect(config.maxRetries == 0)
        #expect(config.baseDelay == 0)
        #expect(config.maxDelay == 0)
        #expect(config.backoffMultiplier == 1.0)
    }
    
    // MARK: - Error Descriptions & Equality
    
    @Test("NetworkError provides correct localized descriptions")
    func networkErrorDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
        #expect(NetworkError.invalidResponse.errorDescription == "Invalid server response")
        #expect(NetworkError.httpError(statusCode: 404).errorDescription == "Server error (code: 404)")
        #expect(NetworkError.decodingError(NSError(domain: "t", code: 1)).errorDescription?.hasPrefix("Failed to parse response:") == true)
        #expect(NetworkError.noData.errorDescription == "No data received")
        #expect(NetworkError.timeout.errorDescription == "Request timed out")
        #expect(NetworkError.networkUnavailable.errorDescription == "Network unavailable")
    }
    
    @Test("NetworkError equality works correctly")
    func networkErrorEquality() {
        #expect(NetworkError.invalidURL == NetworkError.invalidURL)
        #expect(NetworkError.httpError(statusCode: 500) == NetworkError.httpError(statusCode: 500))
        #expect(NetworkError.httpError(statusCode: 404) != NetworkError.httpError(statusCode: 500))
        #expect(NetworkError.invalidURL != NetworkError.invalidResponse)
    }
}
