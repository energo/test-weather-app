//
//  WeatherViewModelTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//

import Testing
import Foundation
@testable import Test_Weather_App

@MainActor
@Suite("WeatherViewModel Tests")
struct WeatherViewModelTests {
    
    // MARK: - Initialization
    
    @Test("ViewModel initializes with correct default state")
    func initialState() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        
        let viewModel = WeatherViewModel(services: [
            .openMeteo: mockOpenMeteo,
            .weatherAPI: mockWeatherAPI
        ])
        
        #expect(viewModel.weatherData == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.locationInput == "")
        #expect(viewModel.selectedServiceType == .openMeteo)
    }
    
    // MARK: - Validation
    
    @Test("Empty location input shows validation error")
    func validationErrorForEmptyInput() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = ""
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Short location input shows validation error")
    func validationErrorForShortInput() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "A"
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Valid location input has no validation error")
    func noValidationErrorForValidInput() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "London"
        #expect(viewModel.validationError == nil)
    }
    
    @Test("ViewModel can fetch weather with valid input")
    func canFetchWeatherWithValidInput() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "London"
        #expect(viewModel.canFetchWeather == true)
    }
    
    @Test("ViewModel cannot fetch weather with invalid input")
    func cannotFetchWeatherWithInvalidInput() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = ""
        #expect(viewModel.canFetchWeather == false)
    }
    
    // MARK: - Fetch Weather
    
    @Test("Fetching weather with valid location succeeds")
    func fetchWeatherSuccess() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "London"
        await viewModel.fetchWeather()
        
        #expect(viewModel.weatherData != nil)
        #expect(viewModel.weatherData?.location == "London")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(mockOpenMeteo.fetchWeatherCalled == true)
    }
    
    @Test("Fetching weather with invalid location does nothing")
    func fetchWeatherWithInvalidLocation() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = ""
        await viewModel.fetchWeather()
        
        #expect(viewModel.weatherData == nil)
        #expect(mockOpenMeteo.fetchWeatherCalled == false)
    }
    
    @Test("Fetching weather handles errors correctly")
    func fetchWeatherError() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "London"
        mockOpenMeteo.shouldThrowError = true
        
        await viewModel.fetchWeather()
        
        #expect(viewModel.weatherData == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Service Toggle
    
    @Test("Toggling service triggers auto-refresh")
    func serviceToggle() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "Paris"
        viewModel.selectedServiceType = .openMeteo
        
        await viewModel.fetchWeather()
        #expect(mockOpenMeteo.fetchWeatherCalled == true)
        
        // Toggle to WeatherAPI
        mockOpenMeteo.fetchWeatherCalled = false
        viewModel.selectedServiceType = .weatherAPI
        
        // Should auto-refresh
        try? await Task.sleep(nanoseconds: 100_000_000) // Small delay for auto-refresh
        
        #expect(mockWeatherAPI.fetchWeatherCalled == true)
    }
    
    @Test("Current service returns correct service for selected type")
    func currentServiceReturnsCorrectService() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.selectedServiceType = .openMeteo
        #expect(viewModel.currentService is MockWeatherService)
        #expect(viewModel.currentService.serviceType == .openMeteo)
        
        viewModel.selectedServiceType = .weatherAPI
        #expect(viewModel.currentService.serviceType == .weatherAPI)
    }
    
    @Test("Current theme changes when service changes")
    func currentThemeChangesWithService() {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.selectedServiceType = .openMeteo
        let openMeteoTheme = viewModel.currentTheme
        
        viewModel.selectedServiceType = .weatherAPI
        let weatherAPITheme = viewModel.currentTheme
        
        // Themes should be different types
        #expect(
            String(describing: type(of: openMeteoTheme)) !=
            String(describing: type(of: weatherAPITheme))
        )
    }
    
    // MARK: - Clear Weather
    
    @Test("Clearing weather resets all state")
    func clearWeather() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        viewModel.locationInput = "London"
        await viewModel.fetchWeather()
        
        #expect(viewModel.weatherData != nil)
        
        viewModel.clearWeather()
        
        #expect(viewModel.weatherData == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.locationInput == "")
    }
    
    // MARK: - Computed Properties
    
    @Test("hasWeatherData reflects current state correctly")
    func hasWeatherData() async {
        let mockOpenMeteo = MockWeatherService(serviceType: .openMeteo)
        let mockWeatherAPI = MockWeatherService(serviceType: .weatherAPI)
        let viewModel = WeatherViewModel(services: [.openMeteo: mockOpenMeteo, .weatherAPI: mockWeatherAPI])
        
        #expect(viewModel.hasWeatherData == false)
        
        viewModel.locationInput = "London"
        await viewModel.fetchWeather()
        
        #expect(viewModel.hasWeatherData == true)
    }
}

// MARK: - Mock Weather Service

final class MockWeatherService: WeatherServiceProtocol {
    let serviceType: WeatherServiceType
    let theme: ServiceTheme
    var shouldThrowError = false
    var fetchWeatherCalled = false
    
    init(serviceType: WeatherServiceType) {
        self.serviceType = serviceType
        self.theme = serviceType == .openMeteo ? OpenMeteoTheme() : WeatherAPITheme()
    }
    
    func fetchWeather(for location: Location) async throws -> WeatherData {
        fetchWeatherCalled = true
        
        if shouldThrowError {
            throw WeatherServiceError.networkError
        }
        
        return WeatherData(
            location: location.name,
            temperature: 20.0,
            feelsLike: 19.0,
            humidity: 60,
            weatherDescription: "Mock Weather",
            windSpeed: 5.0,
            serviceName: serviceType.displayName,
            timestamp: Date()
        )
    }
}
