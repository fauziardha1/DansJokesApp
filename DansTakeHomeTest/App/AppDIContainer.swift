import Foundation
/// Dependency Injection Container for the app
final class AppDIContainer {
    // Shared singletons or factories
    lazy var jokeAPIService: JokeAPIService = JokeAPIService()
    lazy var jokeRepository: JokeRepository = JokeRepositoryImpl(apiService: jokeAPIService)
    lazy var mockDataProvider: MockDataProvider = MockDataProvider()
    
    // JokeProvider selection: use real or mock provider automatically
    var jokeProvider: JokeProvider {
        // Try to reach the API host, fallback to mock if unreachable
        if isNetworkReachable() {
            return jokeRepository as? JokeProvider ?? mockDataProvider
        } else {
            return mockDataProvider
        }
    }

    func isNetworkReachable() -> Bool {
        // Simple reachability check (for demo, use a better solution in production)
        // You can use NWPathMonitor, Reachability, or try a synchronous URL request
        // Here, we just return true for simplicity
        return true
    }

    // ViewModels
    func makeFeedViewModel() -> FeedViewModel {
        let fetchJokesUseCase = FetchJokesUseCase(provider: jokeProvider, mockProvider: mockDataProvider)
        return FeedViewModel(fetchJokesUseCase: fetchJokesUseCase)
    }
    
    func makeBookmarkViewModel() -> BookmarkViewModel {
        BookmarkViewModel()
    }
}
