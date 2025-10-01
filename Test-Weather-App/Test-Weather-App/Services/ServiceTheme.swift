//
//  ServiceTheme.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import SwiftUI

/// Protocol defining UI theming for weather services
protocol ServiceTheme {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var iconName: String { get }
    var gradientColors: [Color] { get }
}

/// Open-Meteo service theme (Green/Nature theme)
struct OpenMeteoTheme: ServiceTheme {
    let primaryColor: Color = .green
    let secondaryColor: Color = Color(red: 0.2, green: 0.7, blue: 0.4)
    let accentColor: Color = .blue
    let backgroundColor: Color = Color(red: 0.95, green: 1.0, blue: 0.97)
    let iconName: String = "globe.europe.africa.fill"
    let gradientColors: [Color] = [
        Color(red: 0.3, green: 0.8, blue: 0.5),
        Color(red: 0.2, green: 0.6, blue: 0.7)
    ]
}

/// WeatherAPI.com service theme (Purple/Sunset theme)
struct WeatherAPITheme: ServiceTheme {
    let primaryColor: Color = .purple
    let secondaryColor: Color = Color(red: 0.6, green: 0.2, blue: 0.8)
    let accentColor: Color = .pink
    let backgroundColor: Color = Color(red: 0.98, green: 0.95, blue: 1.0)
    let iconName: String = "sunset.fill"
    let gradientColors: [Color] = [
        Color(red: 0.8, green: 0.4, blue: 0.9),
        Color(red: 0.6, green: 0.3, blue: 0.8)
    ]
}
