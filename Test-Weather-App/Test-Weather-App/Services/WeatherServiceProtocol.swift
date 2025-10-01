//
//  WeatherServiceProtocol.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Protocol defining weather service contract
/// Any weather service must conform to this protocol for easy replacement
protocol WeatherServiceProtocol {
    /// Service type identifier
    var serviceType: WeatherServiceType { get }
    
    /// Theme associated with this service
    var theme: ServiceTheme { get }
    
    /// Fetches weather data for a given location
    /// - Parameter location: The location to fetch weather for
    /// - Returns: Weather data
    /// - Throws: Error if fetch fails
    func fetchWeather(for location: Location) async throws -> WeatherData
}

/// Weather service errors
enum WeatherServiceError: LocalizedError {
    case invalidLocation
    case networkError
    case invalidResponse
    case locationNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidLocation:
            return "Invalid location provided"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from server"
        case .locationNotFound:
            return "Location not found"
        }
    }
}
