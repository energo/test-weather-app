//
//  WeatherDataTests.swift
//  Test-Weather-AppTests
//
//  Created by D C on 30.09.2025.
//
//  Migrated to Swift Testing (@Test) for modern testing approach

import Testing
import Foundation
@testable import Test_Weather_App

@Suite("WeatherData Model Tests")
struct WeatherDataTests {
    
    // MARK: - Formatted Strings
    
    @Test("Temperature string is formatted correctly with °C suffix")
    func temperatureString() {
        let weatherData = WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "OpenWeather",
            timestamp: Date()
        )
        
        #expect(weatherData.temperatureString == "22.5°C")
    }
    
    @Test("Feels like string is formatted correctly with °C suffix")
    func feelsLikeString() {
        let weatherData = WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "OpenWeather",
            timestamp: Date()
        )
        
        #expect(weatherData.feelsLikeString == "21.3°C")
    }
    
    @Test("Wind speed string is formatted correctly with m/s suffix")
    func windSpeedString() {
        let weatherData = WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "OpenWeather",
            timestamp: Date()
        )
        
        #expect(weatherData.windSpeedString == "5.2 m/s")
    }
    
    @Test("Humidity string is formatted correctly with % suffix")
    func humidityString() {
        let weatherData = WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "OpenWeather",
            timestamp: Date()
        )
        
        #expect(weatherData.humidityString == "65%")
    }
    
    // MARK: - Equality
    
    @Test("WeatherData instances with identical values are equal")
    func weatherDataEquality() {
        let timestamp = Date(timeIntervalSince1970: 0)
        
        let data1 = WeatherData(
            location: "London",
            temperature: 20.0,
            feelsLike: 19.0,
            humidity: 60,
            weatherDescription: "Clear",
            windSpeed: 3.0,
            serviceName: "Test",
            timestamp: timestamp
        )
        
        let data2 = WeatherData(
            location: "London",
            temperature: 20.0,
            feelsLike: 19.0,
            humidity: 60,
            weatherDescription: "Clear",
            windSpeed: 3.0,
            serviceName: "Test",
            timestamp: timestamp
        )
        
        #expect(data1 == data2)
    }
    
    @Test("WeatherData instances with different values are not equal")
    func weatherDataInequality() {
        let data1 = WeatherData(
            location: "London",
            temperature: 20.0,
            feelsLike: 19.0,
            humidity: 60,
            weatherDescription: "Clear",
            windSpeed: 3.0,
            serviceName: "Test",
            timestamp: Date()
        )
        
        let data2 = WeatherData(
            location: "Paris",
            temperature: 25.0,
            feelsLike: 24.0,
            humidity: 55,
            weatherDescription: "Sunny",
            windSpeed: 4.0,
            serviceName: "Test",
            timestamp: Date()
        )
        
        #expect(data1 != data2)
    }
    
    // MARK: - Codable
    
    @Test("WeatherData can be encoded and decoded correctly")
    func weatherDataCodable() throws {
        let originalData = WeatherData(
            location: "London",
            temperature: 22.5,
            feelsLike: 21.3,
            humidity: 65,
            weatherDescription: "Partly Cloudy",
            windSpeed: 5.2,
            serviceName: "OpenWeather",
            timestamp: Date()
        )
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalData)
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(WeatherData.self, from: encodedData)
        
        #expect(originalData.location == decodedData.location)
        #expect(originalData.temperature == decodedData.temperature)
        #expect(originalData.feelsLike == decodedData.feelsLike)
        #expect(originalData.humidity == decodedData.humidity)
        #expect(originalData.weatherDescription == decodedData.weatherDescription)
        #expect(originalData.windSpeed == decodedData.windSpeed)
        #expect(originalData.serviceName == decodedData.serviceName)
    }
}
