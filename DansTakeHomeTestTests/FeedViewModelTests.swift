import XCTest
@testable import DansTakeHomeTest

class FeedViewModelTests: XCTestCase {
    var mockProvider: MockDataProvider!
    var useCase: FetchJokesUseCase!
    var viewModel: FeedViewModel!

    override func setUp() {
        super.setUp()
        mockProvider = MockDataProvider()
        useCase = FetchJokesUseCase(provider: mockProvider, mockProvider: mockProvider)
        viewModel = FeedViewModel(fetchJokesUseCase: useCase)
    }

    override func tearDown() {
        mockProvider = nil
        useCase = nil
        viewModel = nil
        super.tearDown()
    }

    func testInitialLoadFetchesJokes() {
        let expectation = self.expectation(description: "Jokes loaded")
        viewModel.onUpdate = {
            if !self.viewModel.isLoading && !self.viewModel.jokes.isEmpty {
                expectation.fulfill()
            }
        }
        viewModel.loadJokes()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(viewModel.jokes.count, 10)
    }

    func testLoadMoreAppendsJokes() {
        let expectation = self.expectation(description: "Load more jokes")
        viewModel.loadJokes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.loadJokes(loadMore: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(self.viewModel.jokes.count, 20)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }

    func testErrorFallbackToMock() {
        // Simulate a use case that always fails for real data, but returns mock data
        class FailingProvider: JokeProvider {
            func fetchJokes(amount: Int, completion: @escaping (Result<[DansTakeHomeTest.JokeEntity], any Error>) -> Void) {
                completion(.failure(NSError(domain: "Test", code: 1)))
            }
            func fetchJokes(amount: Int, page: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
                completion(.failure(NSError(domain: "Test", code: 1)))
            }
        }
        let failingProvider = FailingProvider()
        let useCase = FetchJokesUseCase(provider: failingProvider, mockProvider: mockProvider)
        let viewModel = FeedViewModel(fetchJokesUseCase: useCase)
        let expectation = self.expectation(description: "Fallback to mock jokes")
        viewModel.onUpdate = {
            if !viewModel.isLoading && !viewModel.jokes.isEmpty {
                expectation.fulfill()
            }
        }
        viewModel.loadJokes()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(viewModel.jokes.count, 10)
    }

    func testNoJokesReturned() {
        // Simulate a provider that returns empty jokes
        class EmptyProvider: JokeProvider {
            func fetchJokes(amount: Int, completion: @escaping (Result<[DansTakeHomeTest.JokeEntity], any Error>) -> Void) {
                completion(.success([]))
            }
            func fetchJokes(amount: Int, page: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
                completion(.success([]))
            }
        }
        let emptyProvider = EmptyProvider()
        let useCase = FetchJokesUseCase(provider: emptyProvider, mockProvider: mockProvider)
        let viewModel = FeedViewModel(fetchJokesUseCase: useCase)
        let expectation = self.expectation(description: "No jokes returned")
        viewModel.onUpdate = {
            if !viewModel.isLoading {
                expectation.fulfill()
            }
        }
        viewModel.loadJokes()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(viewModel.jokes.count, 0)
    }

    func testLoadingState() {
        let expectation = self.expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        viewModel.onUpdate = {
            // Only append if state changed
            if loadingStates.last != self.viewModel.isLoading {
                loadingStates.append(self.viewModel.isLoading)
            }
            // Wait for loading to finish
            if loadingStates.count >= 2 && !self.viewModel.isLoading {
                expectation.fulfill()
            }
        }
        viewModel.loadJokes()
        waitForExpectations(timeout: 2)
        XCTAssertEqual(loadingStates.first, true)
        XCTAssertEqual(loadingStates.last, false)
    }

    func testLoadMoreDoesNotDuplicateJokes() {
        let expectation = self.expectation(description: "No duplicate jokes on load more")
        viewModel.loadJokes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let firstBatchIDs = Set(self.viewModel.jokes.map { $0.id })
            self.viewModel.loadJokes(loadMore: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let allIDs = self.viewModel.jokes.map { $0.id }
                let uniqueIDs = Set(allIDs)
                XCTAssertEqual(allIDs.count, uniqueIDs.count, "Jokes should not be duplicated after load more")
                // Also check that the new batch does not overlap with the first batch
                let secondBatchIDs = Set(self.viewModel.jokes.dropFirst(10).map { $0.id })
                XCTAssertTrue(firstBatchIDs.isDisjoint(with: secondBatchIDs), "Loaded jokes should not overlap")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }

    func testLoadMoreWhenNoMoreJokes() {
        // Simulate a provider that only returns 10 jokes total
        class LimitedProvider: JokeProvider {
            var callCount = 0
            func fetchJokes(amount: Int, completion: @escaping (Result<[DansTakeHomeTest.JokeEntity], any Error>) -> Void) {
                if callCount == 0 {
                    callCount += 1
                    completion(.success((0..<10).map {
                        JokeEntity(id: "\($0)", category: "Test",  type: "twopart", joke: "Joke \($0)", setup: "Setup \($0)", delivery: "Delivery \($0)")
                    }))
                } else {
                    completion(.success([]))
                }
            }
            func fetchJokes(amount: Int, page: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
                if callCount == 0 {
                    callCount += 1
                    completion(.success((0..<10).map {
                        JokeEntity(id: "\($0)", category: "Test",  type: "twopart", joke: "Joke \($0)", setup: "Setup \($0)", delivery: "Delivery \($0)")
                    }))
                } else {
                    completion(.success([]))
                }
            }
        }
        let limitedProvider = LimitedProvider()
        let useCase = FetchJokesUseCase(provider: limitedProvider, mockProvider: mockProvider)
        let viewModel = FeedViewModel(fetchJokesUseCase: useCase)
        let expectation = self.expectation(description: "No more jokes to load")
        viewModel.loadJokes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.loadJokes(loadMore: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(viewModel.jokes.count, 10)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }
}
