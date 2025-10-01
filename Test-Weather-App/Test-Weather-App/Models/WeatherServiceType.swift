//
//  WeatherServiceType.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Enumeration of available weather services
enum WeatherServiceType: String, CaseIterable, Identifiable {
    case openMeteo = "Open-Meteo"
    case weatherAPI = "WeatherAPI"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
}
