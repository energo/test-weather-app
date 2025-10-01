//
//  NetworkLayer.swift
//  Test-Weather-App
//
//  Created by D C on 01.10.2025.
//

import Foundation

// MARK: - URLSession Protocol

/// Protocol for URLSession to enable mocking in tests
protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Network Request Protocol

/// Protocol defining a network request
protocol NetworkRequest {
  associatedtype Response: Decodable
  
  var endpoint: Endpoint { get }
  var headers: [String: String]? { get }
  var timeout: TimeInterval? { get }
}

extension NetworkRequest {
  var headers: [String: String]? { nil }
  var timeout: TimeInterval? { nil }
}

// MARK: - Network Response

/// Generic network response wrapper
struct NetworkResponse<T: Decodable>: Decodable {
  let data: T
  let statusCode: Int
  let headers: [String: String]
}

// MARK: - Network Client Protocol

/// Protocol defining the contract for network operations
protocol NetworkClientProtocol {
  /// Performs a network request
  /// - Parameter request: The network request to perform
  /// - Returns: The decoded response
  func request<T: NetworkRequest>(_ request: T) async throws -> T.Response
  
  /// Performs a request with custom retry configuration
  /// - Parameters:
  ///   - request: The network request to perform
  ///   - retryConfiguration: Custom retry configuration
  /// - Returns: The decoded response
  func request<T: NetworkRequest>(
    _ request: T,
    retryConfiguration: RetryConfiguration
  ) async throws -> T.Response
}

// MARK: - Retry Configuration

/// Configuration for retry behavior
struct RetryConfiguration {
  let maxRetries: Int
  let baseDelay: TimeInterval
  let maxDelay: TimeInterval
  let backoffMultiplier: Double
  let retryableStatusCodes: Set<Int>
  let retryableErrors: Set<URLError.Code>
  
  static let `default` = RetryConfiguration(
    maxRetries: 3,
    baseDelay: 1.0,
    maxDelay: 30.0,
    backoffMultiplier: 2.0,
    retryableStatusCodes: [408, 429, 500, 502, 503, 504],
    retryableErrors: [.notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost]
  )
  
  static let aggressive = RetryConfiguration(
    maxRetries: 5,
    baseDelay: 0.5,
    maxDelay: 60.0,
    backoffMultiplier: 1.5,
    retryableStatusCodes: [408, 429, 500, 502, 503, 504, 520, 521, 522, 523, 524],
    retryableErrors: [.notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost, .dnsLookupFailed]
  )
  
  static let none = RetryConfiguration(
    maxRetries: 0,
    baseDelay: 0,
    maxDelay: 0,
    backoffMultiplier: 1.0,
    retryableStatusCodes: [],
    retryableErrors: []
  )
}

// MARK: - Network Client Implementation

/// Modern network client using async/await with comprehensive error handling and retry logic

final class NetworkClient: NetworkClientProtocol {
  
  private let session: URLSessionProtocol
  private let defaultRetryConfiguration: RetryConfiguration
  private let logger: NetworkLogger?
  
  init(
    session: URLSessionProtocol = URLSession.shared,
    defaultRetryConfiguration: RetryConfiguration = .default,
    logger: NetworkLogger? = NetworkLogger()
  ) {
    self.session = session
    self.defaultRetryConfiguration = defaultRetryConfiguration
    self.logger = logger
  }
  
  // MARK: - Public Methods
  
  func request<T: NetworkRequest>(_ request: T) async throws -> T.Response {
    try await self.request(request, retryConfiguration: defaultRetryConfiguration)
  }
  
  func request<T: NetworkRequest>(
    _ request: T,
    retryConfiguration: RetryConfiguration
  ) async throws -> T.Response {
    logger?.logRequest(request)
    
    guard let url = request.endpoint.url else {
      logger?.logError("Invalid URL for endpoint: \(request.endpoint)")
      throw NetworkError.invalidURL
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.endpoint.method.rawValue
    
    // Add headers
    if let headers = request.headers {
      for (key, value) in headers {
        urlRequest.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    // Set timeout if specified
    if let timeout = request.timeout {
      urlRequest.timeoutInterval = timeout
    }
    
    return try await performRequest(
      urlRequest,
      responseType: T.Response.self,
      retryConfiguration: retryConfiguration,
      attempt: 0
    )
  }
  
  // MARK: - Private Methods
  private func performRequest<T: Decodable>(
    _ urlRequest: URLRequest,
    responseType: T.Type,
    retryConfiguration: RetryConfiguration,
    attempt: Int
  ) async throws -> T {
    do {
      logger?.logAttempt(attempt, urlRequest: urlRequest)
      let (data, response) = try await session.data(for: urlRequest)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        logger?.logError("Invalid HTTP response")
        throw NetworkError.invalidResponse
      }
      
      logger?.logResponse(httpResponse, data: data)
      
      // --- HTTP status handling ---
      guard (200...299).contains(httpResponse.statusCode) else {
        logger?.logError("HTTP error: \(httpResponse.statusCode)")
        throw NetworkError.httpError(statusCode: httpResponse.statusCode)
      }
      
      // --- Decoding ---
      do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
      } catch {
        logger?.logDecodingError(error, data: data)
        throw NetworkError.decodingError(error)
      }
      
    } catch {
      logger?.logError("Request failed: \(error)")
      
      // Normalize error to NetworkError for consistent retry logic
      let mappedError: Error
      if let urlError = error as? URLError {
        switch urlError.code {
        case .timedOut:
          mappedError = NetworkError.timeout
        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .dnsLookupFailed, .cannotFindHost:
          mappedError = NetworkError.networkUnavailable
        default:
          mappedError = urlError
        }
      } else {
        mappedError = error
      }
      
      if shouldRetry(
        error: mappedError,
        attempt: attempt,
        retryConfiguration: retryConfiguration
      ) {
        return try await retryRequest(
          urlRequest,
          responseType: responseType,
          retryConfiguration: retryConfiguration,
          attempt: attempt + 1
        )
      }
      
      throw mappedError
    }
  }


  private func retryRequest<T: Decodable>(
    _ urlRequest: URLRequest,
    responseType: T.Type,
    retryConfiguration: RetryConfiguration,
    attempt: Int
  ) async throws -> T {
    let delay = calculateDelay(
      attempt: attempt,
      configuration: retryConfiguration
    )
    
    logger?.logRetry(attempt, delay: delay)
    
    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    
    return try await performRequest(
      urlRequest,
      responseType: responseType,
      retryConfiguration: retryConfiguration,
      attempt: attempt
    )
  }
  
  private func shouldRetry(
    error: Error,
    attempt: Int,
    retryConfiguration: RetryConfiguration
  ) -> Bool {
    // Check if we've exceeded max retries
    guard attempt < retryConfiguration.maxRetries else {
      return false
    }
    
    // Check HTTP status codes
    if let networkError = error as? NetworkError,
       case .httpError(let statusCode) = networkError {
      return retryConfiguration.retryableStatusCodes.contains(statusCode)
    }
    
    // Check URL errors
    if let urlError = error as? URLError {
      return retryConfiguration.retryableErrors.contains(urlError.code)
    }
    
    return false
  }
  
  private func calculateDelay(
    attempt: Int,
    configuration: RetryConfiguration
  ) -> TimeInterval {
    let exponentialDelay = configuration.baseDelay * pow(configuration.backoffMultiplier, Double(attempt))
    let jitter = Double.random(in: 0.1...0.3) // Add jitter to prevent thundering herd
    let delay = exponentialDelay * (1 + jitter)
    
    return min(delay, configuration.maxDelay)
  }
}

// MARK: - Network Logger

/// Logger for network operations
final class NetworkLogger {
  private let isEnabled: Bool
  
  init(isEnabled: Bool = true) {
#if DEBUG
    self.isEnabled = isEnabled
#else
    self.isEnabled = false
#endif
  }
  
  func logRequest<T: NetworkRequest>(_ request: T) {
    guard isEnabled else { return }
    print("🌐 [NETWORK] Request: \(request.endpoint.method.rawValue) \(request.endpoint.url?.absoluteString ?? "Invalid URL")")
  }
  
  func logAttempt(_ attempt: Int, urlRequest: URLRequest) {
    guard isEnabled else { return }
    if attempt > 0 {
      print("🔄 [NETWORK] Retry attempt \(attempt)")
    }
    print("📤 [NETWORK] Making request to: \(urlRequest.url?.absoluteString ?? "Unknown URL")")
  }
  
  func logResponse(_ response: HTTPURLResponse, data: Data) {
    guard isEnabled else { return }
    print("📥 [NETWORK] Response: \(response.statusCode) (\(data.count) bytes)")
  }
  
  func logRetry(_ attempt: Int, delay: TimeInterval) {
    guard isEnabled else { return }
    print("⏳ [NETWORK] Waiting \(String(format: "%.2f", delay))s before retry \(attempt)")
  }
  
  func logError(_ message: String) {
    guard isEnabled else { return }
    print("❌ [NETWORK] Error: \(message)")
  }
  
  func logDecodingError(_ error: Error, data: Data) {
    guard isEnabled else { return }
    print("🔴 [NETWORK] Decoding Error: \(error)")
    
    if let jsonString = String(data: data, encoding: .utf8) {
      print("📄 [NETWORK] JSON preview: \(String(jsonString.prefix(200)))...")
    }
  }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError, Equatable {
  case invalidURL
  case invalidResponse
  case httpError(statusCode: Int)
  case decodingError(Error)
  case noData
  case timeout
  case networkUnavailable
  
  var errorDescription: String? {
    switch self {
      case .invalidURL:
        return "Invalid URL"
      case .invalidResponse:
        return "Invalid server response"
      case .httpError(let statusCode):
        return "Server error (code: \(statusCode))"
      case .decodingError(let error):
        return "Failed to parse response: \(error.localizedDescription)"
      case .noData:
        return "No data received"
      case .timeout:
        return "Request timed out"
      case .networkUnavailable:
        return "Network unavailable"
    }
  }
  
  static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
      case (.invalidURL, .invalidURL),
        (.invalidResponse, .invalidResponse),
        (.noData, .noData),
        (.timeout, .timeout),
        (.networkUnavailable, .networkUnavailable):
        return true
      case (.httpError(let lhsCode), .httpError(let rhsCode)):
        return lhsCode == rhsCode
      case (.decodingError(let lhsError), .decodingError(let rhsError)):
        return lhsError.localizedDescription == rhsError.localizedDescription
      default:
        return false
    }
  }
}
