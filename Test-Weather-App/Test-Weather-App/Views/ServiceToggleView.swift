//
//  ServiceToggleView.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import SwiftUI

/// View for toggling between weather services
struct ServiceToggleView: View {
  
  @Binding var selectedService: WeatherServiceType
  let theme: ServiceTheme
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: theme.iconName)
          .font(.title2)
          .foregroundStyle(theme.accentColor)
          .frame(width: 28, height: 28)
        
        Text("Weather Service")
          .font(.headline)
          .foregroundStyle(.white)
        
        Spacer()
      }
      
      Picker("Select Service", selection: $selectedService) {
        ForEach(WeatherServiceType.allCases) { service in
          Text(service.displayName)
            .tag(service)
        }
      }
      .pickerStyle(.segmented)
      .colorMultiply(theme.primaryColor.opacity(0.5))
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.white.opacity(0.2))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    )
  }
}

#Preview {
  ServiceToggleView(
    selectedService: .constant(.openMeteo),
    theme: OpenMeteoTheme()
  )
  .padding()
  .background(Color.green)
}
