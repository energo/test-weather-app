//
//  WeatherDisplayView.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import SwiftUI

/// View for displaying weather data
struct WeatherDisplayView: View {
    
    let weatherData: WeatherData
    let theme: ServiceTheme
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: weatherData.timestamp)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text(weatherData.location)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(weatherData.serviceName)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
            }
            
            // Main Temperature
            HStack(alignment: .top, spacing: 4) {
                Text(String(format: "%.0f", weatherData.temperature))
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.white)
                
                Text("°C")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 8)
            }
            
            Text(weatherData.weatherDescription)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
            
            Divider()
                .background(.white.opacity(0.3))
                .padding(.vertical, 8)
            
            // Weather Details Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                WeatherDetailItem(
                    icon: "thermometer.medium",
                    label: "Feels Like",
                    value: weatherData.feelsLikeString,
                    theme: theme
                )
                
                WeatherDetailItem(
                    icon: "humidity.fill",
                    label: "Humidity",
                    value: weatherData.humidityString,
                    theme: theme
                )
                
                WeatherDetailItem(
                    icon: "wind",
                    label: "Wind Speed",
                    value: weatherData.windSpeedString,
                    theme: theme
                )
                
                WeatherDetailItem(
                    icon: "clock.fill",
                    label: "Updated",
                    value: formattedTimestamp.components(separatedBy: ",").last ?? "",
                    theme: theme
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.25))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Weather Detail Item

private struct WeatherDetailItem: View {
    let icon: String
    let label: String
    let value: String
    let theme: ServiceTheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(theme.accentColor)
                .frame(height: 30)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
        )
    }
}

#Preview {
    WeatherDisplayView(
        weatherData: WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "Open-Meteo",
            timestamp: Date()
        ),
        theme: OpenMeteoTheme()
    )
    .padding()
    .background(
        LinearGradient(
            colors: [Color.green, Color.mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
