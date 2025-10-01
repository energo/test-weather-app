//
//  WeatherData.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Universal weather data model used across all weather services
struct WeatherData: Equatable, Codable {
    let location: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let weatherDescription: String
    let windSpeed: Double
    let serviceName: String
    let timestamp: Date
    
    /// Temperature in Celsius as a formatted string
    var temperatureString: String {
        String(format: "%.1f°C", temperature)
    }
    
    /// Feels like temperature in Celsius as a formatted string
    var feelsLikeString: String {
        String(format: "%.1f°C", feelsLike)
    }
    
    /// Wind speed in m/s as a formatted string
    var windSpeedString: String {
        String(format: "%.1f m/s", windSpeed)
    }
    
    /// Humidity as a percentage string
    var humidityString: String {
        "\(humidity)%"
    }
}
