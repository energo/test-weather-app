//
//  WeatherViewModel.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation
import SwiftUI

/// Main ViewModel managing weather app state and business logic
@MainActor
@Observable
final class WeatherViewModel {
    
    // MARK: - Published State
    
    private(set) var weatherData: WeatherData?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var locationInput: String = ""
    var selectedServiceType: WeatherServiceType = .openMeteo {
        didSet {
            if oldValue != selectedServiceType {
                serviceDidChange()
            }
        }
    }
    
    // MARK: - Dependencies
    
    private var services: [WeatherServiceType: WeatherServiceProtocol]
    
    // MARK: - Computed Properties
    
    var currentService: WeatherServiceProtocol {
        services[selectedServiceType]!
    }
    
    var currentTheme: ServiceTheme {
        currentService.theme
    }
    
    var hasWeatherData: Bool {
        weatherData != nil
    }
    
    var validationError: String? {
        LocationValidator.validationError(for: locationInput)
    }
    
    var canFetchWeather: Bool {
        !isLoading && validationError == nil && !locationInput.isEmpty
    }
    
    // MARK: - Initialization
    
    init(services: [WeatherServiceType: WeatherServiceProtocol]? = nil) {
        if let services = services {
            self.services = services
        } else {
            // Default services
            self.services = [
                .openMeteo: OpenMeteoService(),
                .weatherAPI: WeatherAPIService()
            ]
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetches weather for the current location input
    func fetchWeather() async {
        guard canFetchWeather else { return }
        
        guard let location = Location(name: locationInput) else {
            errorMessage = "Invalid location"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await currentService.fetchWeather(for: location)
            weatherData = data
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            weatherData = nil
        }
        
        isLoading = false
    }
    
    /// Clears all weather data and resets state
    func clearWeather() {
        weatherData = nil
        errorMessage = nil
        locationInput = ""
    }
    
    // MARK: - Private Methods
    
    /// Called when service type changes
    /// Automatically refreshes weather if location is already set
    private func serviceDidChange() {
        // Auto-refresh if we already have a location
        if hasWeatherData || !locationInput.isEmpty {
            Task {
                await fetchWeather()
            }
        }
    }
}
