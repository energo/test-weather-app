//
//  OpenMeteoService.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation
import CoreLocation

/// Open-Meteo service implementation
/// FREE API - No API key required!
/// Documentation: https://open-meteo.com
/// GitHub: https://github.com/open-meteo/open-meteo
final class OpenMeteoService: WeatherServiceProtocol {
    
    let serviceType: WeatherServiceType = .openMeteo
    let theme: ServiceTheme = OpenMeteoTheme()
    
    private let networkClient: NetworkClientProtocol
    private let geocoder = CLGeocoder()
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func fetchWeather(for location: Location) async throws -> WeatherData {
        print("\n🌍 ========== OPEN-METEO API DEBUG ==========")
        print("📍 Requesting weather for: \(location.name)")
        
        // First, geocode the location to get coordinates
        let coordinates = try await geocodeLocation(location.name)
        print("🗺️  Coordinates: \(coordinates.latitude), \(coordinates.longitude)")
        
        // Create and perform the request
        let request = OpenMeteoForecastRequest(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
        
        let response = try await networkClient.request(request)
        
        print("📊 Temperature: \(response.current.temperature2m)°C")
        print("💧 Humidity: \(response.current.relativeHumidity2m)%")
        print("🌡️  Feels like: \(response.current.apparentTemperature)°C")
        print("🌬️  Wind: \(response.current.windSpeed10m) m/s")
        print("☁️  Weather code: \(response.current.weatherCode)")
        print("✅ Open-Meteo request successful!")
        
        return WeatherData(
            location: location.name,
            temperature: response.current.temperature2m,
            feelsLike: response.current.apparentTemperature,
            humidity: response.current.relativeHumidity2m,
            weatherDescription: weatherDescription(from: response.current.weatherCode),
            windSpeed: response.current.windSpeed10m,
            serviceName: "Open-Meteo",
            timestamp: Date()
        )
    }
    
    // MARK: - Private Methods
    
    /// Geocodes a location name to coordinates
    private func geocodeLocation(_ locationName: String) async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(locationName) { placemarks, error in
                if let error = error {
                    print("❌ Geocoding error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    print("❌ No location found for: \(locationName)")
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                
                continuation.resume(returning: location.coordinate)
            }
        }
    }
    
    /// Converts weather code to human-readable description
    private func weatherDescription(from code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 56, 57: return "Freezing drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing rain"
        case 71, 73, 75: return "Snow fall"
        case 77: return "Snow grains"
        case 80, 81, 82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm with hail"
        default: return "Unknown"
        }
    }
}