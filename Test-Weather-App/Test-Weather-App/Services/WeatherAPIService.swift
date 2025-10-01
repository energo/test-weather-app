//
//  WeatherAPIService.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// WeatherAPI.com service implementation
/// Documentation: https://www.weatherapi.com/docs/
/// Website: https://www.weatherapi.com
final class WeatherAPIService: WeatherServiceProtocol {
    
    let serviceType: WeatherServiceType = .weatherAPI
    let theme: ServiceTheme = WeatherAPITheme()
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func fetchWeather(for location: Location) async throws -> WeatherData {
        print("\n🌅 ========== WEATHERAPI.COM DEBUG ==========")
        print("📍 Requesting weather for: \(location.name)")
        
        // Create and perform the request
        let request = WeatherAPICurrentRequest(
            location: location.name,
            apiKey: APIConfiguration.WeatherAPI.apiKey
        )
        
        let response = try await networkClient.request(request)
        
        print("📊 Temperature: \(response.current.tempC)°C")
        print("💧 Humidity: \(response.current.humidity)%")
        print("🌡️  Feels like: \(response.current.feelslikeC)°C")
        print("🌬️  Wind: \(response.current.windKph) km/h")
        print("☁️  Condition: \(response.current.condition.text)")
        print("✅ WeatherAPI.com request successful!")
        
        return WeatherData(
            location: location.name,
            temperature: response.current.tempC,
            feelsLike: response.current.feelslikeC,
            humidity: response.current.humidity,
            weatherDescription: response.current.condition.text,
            windSpeed: response.current.windKph / 3.6, // Convert km/h to m/s
            serviceName: "WeatherAPI.com",
            timestamp: Date()
        )
    }
}