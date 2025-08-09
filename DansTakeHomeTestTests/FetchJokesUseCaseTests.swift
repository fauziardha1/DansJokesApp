import XCTest
@testable import DansTakeHomeTest

class FetchJokesUseCaseTests: XCTestCase {
    var mockProvider: MockJokeRepository!
    var provider: MockJokeRepository!
    var useCase: FetchJokesUseCase!

    override func setUp() {
        super.setUp()
        provider = MockJokeRepository()
        mockProvider = MockJokeRepository()
        useCase = FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
    }

    override func tearDown() {
        provider = nil
        mockProvider = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: - Helper
    func makeUseCase(providerJokes: [JokeEntity] = [], providerError: Error? = nil, mockJokes: [JokeEntity] = [], mockError: Error? = nil) -> FetchJokesUseCase {
        let provider = MockJokeRepository()
        let mockProvider = MockJokeRepository()
        provider.jokesToReturn = providerJokes
        provider.errorToReturn = providerError
        mockProvider.jokesToReturn = mockJokes
        mockProvider.errorToReturn = mockError
        self.provider = provider
        self.mockProvider = mockProvider
        return FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
    }

    func test_fetchJokes_withMockDataFalse_fetchSuccess_returnsJokes() {
        // Arrange
        let mockJokes = [JokeEntity(id: "1", category: "Test",  type: "twopart", joke: "Joke 1", setup: "Setup 1", delivery: "Delivery 1")]
        let useCase = makeUseCase(providerJokes: mockJokes)
        let expectation = XCTestExpectation(description: "Fetch jokes")

        // Act
        useCase.fetchJokes(amount: 1, useMockData: false) { result in
            // Assert
            switch result {
            case .success(let jokes):
                XCTAssertEqual(jokes, mockJokes)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            XCTAssertTrue(self.provider.fetchCalled)
            XCTAssertFalse(self.mockProvider.fetchCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchJokes_withMockDataFalse_fetchFailed_returnsErrorWithNoJoke() {
        // Arrange
        let useCase = makeUseCase(providerJokes: [], providerError: NSError(domain: "TestError", code: 1), mockJokes: [], mockError: NSError(domain: "TestError", code: 2))
        let expectation = XCTestExpectation(description: "Fetch jokes")

        // Act
        useCase.fetchJokes(amount: 1, useMockData: false) { result in
            // Assert
            switch result {
            case .success(_):
                XCTFail("Expected failed but got success")
            case .failure(let error):
                XCTAssertNotNil(error, "Expected an error but got none")
            }
            XCTAssertTrue(self.provider.fetchCalled)
            XCTAssertFalse(self.mockProvider.fetchCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchJokes_withMockDataTrue_fetchSuccess_returnsJokes() {
        // Arrange
        let mockJokes = [JokeEntity(id: "1", category: "Test",  type: "twopart", joke: "Joke 1", setup: "Setup 1", delivery: "Delivery 1")]
        let useCase = makeUseCase(mockJokes: mockJokes)
        let expectation = XCTestExpectation(description: "Fetch jokes")

        // Act
        useCase.fetchJokes(amount: 1, useMockData: true) { result in
            // Assert
            switch result {
            case .success(let jokes):
                XCTAssertEqual(jokes, mockJokes)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            XCTAssertTrue(self.mockProvider.fetchCalled)
            XCTAssertFalse(self.provider.fetchCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchJokes_withMockDataTrue_fetchFailed_returnsErrorWithNoJoke() {
        // Arrange
        let useCase = makeUseCase(mockJokes: [], mockError: NSError(domain: "TestError", code: 1))
        let expectation = XCTestExpectation(description: "Fetch jokes")

        // Act
        useCase.fetchJokes(amount: 1, useMockData: true) { result in
            // Assert
            switch result {
            case .success(_):
                XCTFail("Expected failed but got success")
            case .failure(let error):
                XCTAssertNotNil(error, "Expected an error but got none")
            }
            XCTAssertTrue(self.mockProvider.fetchCalled)
            XCTAssertFalse(self.provider.fetchCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    class MockJokeRepository: JokeRepository {
        var fetchCalled = false
        var jokesToReturn: [JokeEntity] = []
        var errorToReturn: Error?
        func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
            fetchCalled = true
            if let error = errorToReturn {
                completion(.failure(error))
            } else {
                completion(.success(jokesToReturn))
            }
        }
    }
}
