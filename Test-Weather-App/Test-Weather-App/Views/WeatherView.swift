//
//  WeatherView.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import SwiftUI

/// Main weather view containing all UI components
struct WeatherView: View {
    
    @State private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient based on selected service theme
                LinearGradient(
                    colors: viewModel.currentTheme.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Service Toggle
                        ServiceToggleView(
                            selectedService: $viewModel.selectedServiceType,
                            theme: viewModel.currentTheme
                        )
                        .padding(.top, 16)
                        
                        // Location Input
                        LocationInputView(
                            locationInput: $viewModel.locationInput,
                            validationError: viewModel.validationError,
                            canFetch: viewModel.canFetchWeather,
                            isLoading: viewModel.isLoading,
                            theme: viewModel.currentTheme,
                            onFetch: {
                                Task {
                                    await viewModel.fetchWeather()
                                }
                            }
                        )
                        
                        // Weather Display
                        if let weatherData = viewModel.weatherData {
                            WeatherDisplayView(
                                weatherData: weatherData,
                                theme: viewModel.currentTheme
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            ErrorMessageView(message: errorMessage)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Weather App")
            .navigationBarTitleDisplayMode(.large)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedServiceType)
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: viewModel.weatherData)
        }
    }
}

// MARK: - Error Message View

private struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(message)
                .foregroundStyle(.white)
                .font(.subheadline)
        }
        .padding()
        .background(Color.red.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}

#Preview {
    WeatherView()
}
