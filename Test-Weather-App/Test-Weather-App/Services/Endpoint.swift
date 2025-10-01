//
//  Endpoint.swift
//  Test-Weather-App
//
//  Created by D C on 01.10.2025.
//

import Foundation

/// HTTP method for API requests
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Type-safe API endpoint configuration
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let baseURL: String
    
    init(
        baseURL: String,
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
    
    /// Builds the complete URL for this endpoint
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

// MARK: - Weather API Endpoints

extension Endpoint {
    
    /// Open-Meteo forecast endpoint
    static func openMeteoForecast(
        latitude: Double,
        longitude: Double
    ) -> Endpoint {
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
    
    /// WeatherAPI.com current weather endpoint
    static func weatherAPICurrent(
        location: String,
        apiKey: String
    ) -> Endpoint {
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
}

