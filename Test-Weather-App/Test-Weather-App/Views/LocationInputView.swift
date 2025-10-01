//
//  LocationInputView.swift
//  Test-Weather-App
//
//  Created by D C on 30.09.2025.
//

import SwiftUI

/// View for location input with validation
struct LocationInputView: View {
    
    @Binding var locationInput: String
    let validationError: String?
    let canFetch: Bool
    let isLoading: Bool
    let theme: ServiceTheme
    let onFetch: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter Location")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                // Text Field
                TextField("City name...", text: $locationInput)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                    )
                    .focused($isTextFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        if canFetch {
                            onFetch()
                        }
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                // Search Button
                Button {
                    isTextFieldFocused = false
                    onFetch()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(canFetch ? theme.primaryColor : Color.gray)
                    )
                }
                .disabled(!canFetch)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
            }
            
            // Validation Error
            if let validationError = validationError, !locationInput.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.yellow)
                    Text(validationError)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.2), value: validationError)
    }
}

#Preview {
    LocationInputView(
        locationInput: .constant("London"),
        validationError: nil,
        canFetch: true,
        isLoading: false,
        theme: OpenMeteoTheme(),
        onFetch: {}
    )
    .padding()
    .background(Color.green)
}
