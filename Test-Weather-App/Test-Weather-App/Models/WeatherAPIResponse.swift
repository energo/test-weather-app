//
//  WeatherAPIResponse.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// WeatherAPI.com Response Model (Minimal)
/// Endpoint: https://api.weatherapi.com/v1/current.json
/// Documentation: https://www.weatherapi.com/docs/
/// 
/// This model only decodes the fields we need, ignoring all extra fields
/// like short_rad, diff_rad, dni, gti (available for paid plans)
struct WeatherAPIResponse: Codable {
    let location: LocationInfo
    let current: CurrentWeather
    
    /// Location information
    struct LocationInfo: Codable {
        let name: String
        
        // We only need the name, ignore everything else
    }
    
    /// Current weather data
    struct CurrentWeather: Codable {
        let tempC: Double
        let humidity: Int
        let feelslikeC: Double
        let windKph: Double
        let condition: Condition
        
        struct Condition: Codable {
            let text: String
        }
        
        enum CodingKeys: String, CodingKey {
            case tempC = "temp_c"
            case humidity
            case feelslikeC = "feelslike_c"
            case windKph = "wind_kph"
            case condition
        }
    }
    
    /// Converts API response to our app's WeatherData model
    func toWeatherData() -> WeatherData {
        WeatherData(
            location: location.name,
            temperature: current.tempC,
            feelsLike: current.feelslikeC,
            humidity: current.humidity,
            weatherDescription: current.condition.text,
            windSpeed: current.windKph / 3.6, // Convert km/h to m/s
            serviceName: "WeatherAPI",
            timestamp: Date()
        )
    }
}
