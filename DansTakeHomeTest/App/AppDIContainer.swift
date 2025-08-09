import Foundation
/// Dependency Injection Container for the app
final class AppDIContainer {
    // Shared singletons or factories
    lazy var jokeAPIService: JokeAPIService = JokeAPIService()
    lazy var jokeRepository: JokeRepository = JokeRepositoryImpl(apiService: jokeAPIService)
    lazy var mockDataProvider: MockDataProvider = MockDataProvider()

    // ViewModels
    func makeFeedViewModel() -> FeedViewModel {
        let fetchJokesUseCase = FetchJokesUseCase(provider: jokeRepository, mockProvider: mockDataProvider)
        return FeedViewModel(fetchJokesUseCase: fetchJokesUseCase)
    }
    
    func makeBookmarkViewModel() -> BookmarkViewModel {
        BookmarkViewModel()
    }
}
