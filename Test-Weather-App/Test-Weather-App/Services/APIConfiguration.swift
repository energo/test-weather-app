//
//  APIConfiguration.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import Foundation

/// Configuration for weather API services
enum APIConfiguration {
    
    /// Open-Meteo API Configuration
    /// FREE - No API key required!
    enum OpenMeteo {
        static let baseURL = "https://api.open-meteo.com/v1"
        // Completely free, no API key needed!
        // Unlimited requests for non-commercial use
        // Documentation: https://open-meteo.com
        // GitHub: https://github.com/open-meteo/open-meteo
    }
    
    /// WeatherAPI.com Configuration
    enum WeatherAPI {
        static let baseURL = "https://api.weatherapi.com/v1"
        static let apiKey = "43bd4b8134d546659be212635253009" // Your API key
        // Free tier
        // Documentation: https://www.weatherapi.com/docs/
        // Website: https://www.weatherapi.com
    }
}

// MARK: - API Instructions
/*
 To use real weather data:
 
 1. Open-Meteo (RECOMMENDED - FREE, NO API KEY!):
    ✅ Already configured and working!
    ✅ No sign up needed
    ✅ Unlimited requests for non-commercial use
    ✅ Documentation: https://open-meteo.com
    ✅ GitHub: https://github.com/open-meteo/open-meteo
 
 2. WeatherAPI.com:
    ✅ Already configured with API key!
    ✅ 1,000,000 calls/month free tier
    - Documentation: https://www.weatherapi.com/docs/
    - Website: https://www.weatherapi.com
    - Sign up: https://www.weatherapi.com/signup.aspx
 
 Note: Both services work immediately!
 Open-Meteo has unlimited requests, WeatherAPI has 1M/month.
 */

