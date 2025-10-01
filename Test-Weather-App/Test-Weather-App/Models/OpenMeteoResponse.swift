//
//  OpenMeteoResponse.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Open-Meteo API Response Model
/// Endpoint: https://api.open-meteo.com/v1/forecast
/// Documentation: https://open-meteo.com/en/docs
struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentWeather
    
    struct CurrentWeather: Codable {
        let time: String
        let temperature2m: Double
        let relativeHumidity2m: Int
        let apparentTemperature: Double
        let weatherCode: Int
        let windSpeed10m: Double
        
        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
        }
    }
    
    /// Converts API response to our app's WeatherData model
    func toWeatherData(locationName: String) -> WeatherData {
        WeatherData(
            location: locationName,
            temperature: current.temperature2m,
            feelsLike: current.apparentTemperature,
            humidity: current.relativeHumidity2m,
            weatherDescription: weatherCodeToDescription(current.weatherCode),
            windSpeed: current.windSpeed10m / 3.6, // Convert km/h to m/s
            serviceName: "Open-Meteo",
            timestamp: Date()
        )
    }
    
    /// Converts WMO weather code to human-readable description
    /// https://open-meteo.com/en/docs
    private func weatherCodeToDescription(_ code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow grains"
        case 80, 81, 82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm with hail"
        default: return "Unknown"
        }
    }
}
