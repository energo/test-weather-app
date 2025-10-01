//
//  WeatherRequests.swift
//  Test-Weather-App
//
//  Created by D C on 01.10.2025.
//

import Foundation

// MARK: - Open-Meteo Requests

/// Open-Meteo forecast request
struct OpenMeteoForecastRequest: NetworkRequest {
    typealias Response = OpenMeteoResponse
    
    let latitude: Double
    let longitude: Double
    
    var endpoint: Endpoint {
        Endpoint(
            baseURL: APIConfiguration.OpenMeteo.baseURL,
            path: "/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
                URLQueryItem(name: "timezone", value: "auto")
            ]
        )
    }
    
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "User-Agent": "Test-Weather-App/1.0"
        ]
    }
    
    var timeout: TimeInterval? { 30.0 }
}

// MARK: - WeatherAPI Requests

/// WeatherAPI.com current weather request
struct WeatherAPICurrentRequest: NetworkRequest {
    typealias Response = WeatherAPIResponse
    
    let location: String
    let apiKey: String
    
    var endpoint: Endpoint {
        Endpoint(
            baseURL: APIConfiguration.WeatherAPI.baseURL,
            path: "/current.json",
            queryItems: [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "q", value: location),
                URLQueryItem(name: "aqi", value: "no")
            ]
        )
    }
    
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "User-Agent": "Test-Weather-App/1.0"
        ]
    }
    
    var timeout: TimeInterval? { 30.0 }
}

