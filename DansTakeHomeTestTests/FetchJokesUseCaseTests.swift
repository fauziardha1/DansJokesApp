import XCTest
@testable import DansTakeHomeTest

class FetchJokesUseCaseTests: XCTestCase {
    var mockProvider: MockDataProvider!
    var useCase: FetchJokesUseCase!

    override func setUp() {
        super.setUp()
        mockProvider = MockDataProvider()
        useCase = FetchJokesUseCase(provider: mockProvider, mockProvider: mockProvider)
    }

    override func tearDown() {
        mockProvider = nil
        useCase = nil
        super.tearDown()
    }

    func test_FetchJokesWithUseMockDatFalse_FetchFailed_ReturnEmptyJokes() {
        
    }
    
    func test_fetchJokes_withMockDataFalse_fetchSuccess_returnsJokes() {
        // Arrange
        let mockJokes = [JokeEntity(id: "1", category: "Test",  type: "twopart", joke: "Joke 1", setup: "Setup 1", delivery: "Delivery 1")]
                         
        let provider = MockJokeRepository()
        let mockProvider = MockJokeRepository()
        provider.jokesToReturn = mockJokes

        let useCase = FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
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
            XCTAssertTrue(provider.fetchCalled)
            XCTAssertFalse(mockProvider.fetchCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchJokes_withMockDataFalse_fetchFailed_returnsErrorWithNoJoke() {
                         
        let provider = MockJokeRepository()
        let mockProvider = MockJokeRepository()
        provider.errorToReturn = NSError(domain: "TestError", code: 1, userInfo: nil)

        let useCase = FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
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
            XCTAssertTrue(provider.fetchCalled)
            XCTAssertFalse(mockProvider.fetchCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchJokes_withMockDataTue_fetchSuccess_returnsJokes() {
        // Arrange
        let mockJokes = [JokeEntity(id: "1", category: "Test",  type: "twopart", joke: "Joke 1", setup: "Setup 1", delivery: "Delivery 1")]
                         
        let provider = MockJokeRepository()
        let mockProvider = MockJokeRepository()
        mockProvider.jokesToReturn = mockJokes

        let useCase = FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
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
            XCTAssertTrue(mockProvider.fetchCalled)
            XCTAssertFalse(provider.fetchCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchJokes_withMockDataTrue_fetchFailed_returnsErrorWithNoJoke() {
                         
        let provider = MockJokeRepository()
        let mockProvider = MockJokeRepository()
        mockProvider.errorToReturn = NSError(domain: "TestError", code: 1, userInfo: nil)

        let useCase = FetchJokesUseCase(provider: provider, mockProvider: mockProvider)
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
            XCTAssertTrue(mockProvider.fetchCalled)
            XCTAssertFalse(provider.fetchCalled)
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
