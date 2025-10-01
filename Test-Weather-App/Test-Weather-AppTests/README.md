# Unit Tests - Best Practices

This test suite follows modern Swift Concurrency best practices for testing async/await code.

## Key Principles

### 1. **Mock Network Requests**
✅ **DO**: Use `MockURLSession` actor to simulate network responses  
❌ **DON'T**: Make real network calls in unit tests

```swift
// Good ✅
let mockSession = MockURLSession()
await mockSession.setSuccessResponse(for: url, jsonData: mockData)
let client = NetworkClient(session: mockSession)

// Bad ❌
let client = NetworkClient(session: URLSession.shared) // Real network!
```

### 2. **Use `async throws` in Test Methods**
✅ **DO**: Mark test methods with `async throws` for clean async code  
❌ **DON'T**: Use Task wrappers or completion handlers

```swift
// Good ✅
func testFetchWeather() async throws {
    let result = try await service.fetchWeather(for: location)
    XCTAssertNotNil(result)
}

// Bad ❌
func testFetchWeather() {
    let expectation = expectation(description: "...")
    Task {
        // Complex expectation handling
    }
}
```

### 3. **Use `@MainActor` for UI Tests**
✅ **DO**: Use `@MainActor` when testing MainActor-isolated types  
❌ **DON'T**: Forget actor isolation - it causes build errors

```swift
// Good ✅
@MainActor
final class WeatherViewModelTests: XCTestCase {
    func testViewModel() async {
        let viewModel = WeatherViewModel() // No await needed
        XCTAssertNotNil(viewModel.weatherData)
    }
}

// Bad ❌
final class WeatherViewModelTests: XCTestCase {
    func testViewModel() async {
        let viewModel = await WeatherViewModel() // Unnecessary await
    }
}
```

### 4. **Actor-Based Mocks for Swift 6**
✅ **DO**: Use `actor` for thread-safe mock objects  
❌ **DON'T**: Use NSLock in async contexts (causes warnings/errors)

```swift
// Good ✅
actor MockURLSession: URLSessionProtocol {
    private var mockResponses: [URL: MockResponse] = [:]
    
    func setMockResponse(for url: URL, response: MockResponse) {
        mockResponses[url] = response // Actor-isolated
    }
}

// Bad ❌
class MockURLSession: URLSessionProtocol {
    private let lock = NSLock()
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lock.lock() // ⚠️ Warning: NSLock in async context!
        defer { lock.unlock() }
        // ...
    }
}
```

### 5. **Avoid Expectations with Async/Await**
✅ **DO**: Use direct `await` for async operations  
❌ **DON'T**: Mix old `XCTestExpectation` with new concurrency

```swift
// Good ✅
func testAsync() async {
    await service.performOperation()
    XCTAssertTrue(service.completed)
}

// Bad ❌
func testAsync() {
    let expectation = expectation(description: "...")
    Task {
        await service.performOperation()
        expectation.fulfill()
    }
    wait(for: [expectation]) // ⚠️ Can cause deadlocks!
}
```

## Test Structure

### NetworkClientTests
- Tests the generic network client with mock URLSession
- Validates retry logic, error handling, and response decoding
- Uses `@MainActor` for consistency with app context

### WeatherServiceTests
- Tests OpenMeteo and WeatherAPI service implementations
- Uses `MockNetworkClient` actor for isolated testing
- Validates proper mapping from API responses to `WeatherData`

### WeatherViewModelTests
- Tests business logic and state management
- Uses `@MainActor` (required for `@Observable` ViewModel)
- Uses mock services for predictable test data

## Running Tests

```bash
# Run all tests
cmd + U in Xcode

# Run specific test class
xcodebuild test -scheme Test-Weather-App \
  -only-testing:Test-Weather-AppTests/NetworkClientTests

# Run with test repetitions to check for flakiness
# Product > Perform Action > Run Test... (multiple times)
```

## References

- [Unit testing async/await Swift code](https://www.avanderlee.com/concurrency/unit-testing-async-await/)
- [Testing Network Layer in Swift](https://medium.com/@mctok/testing-network-layer-in-swift-53e34b62f70c)
- [Swift Testing: How to test your iOS app's network layer](https://feyyazonur.medium.com/swift-testing-how-to-test-your-ios-apps-network-layer-957643b6d365)
- [Network Layer Best Practices](https://github.com/onurfeyyaz/network-layer)

## Common Issues

### Issue: "Main actor-isolated property cannot be referenced..."
**Solution**: Add `@MainActor` to the test class

### Issue: Tests are slow or flaky
**Solution**: Check if you're making real network calls. Use mocks instead.

### Issue: "NSLock in async context" warning
**Solution**: Use `actor` instead of NSLock for thread-safe mocks

### Issue: Undefined symbols when linking tests
**Solution**: Ensure `TEST_HOST` is set in test target build settings

