// UseCase for fetching jokes
class FetchJokesUseCase {
    private let provider: JokeRepository
    private let mockProvider: JokeRepository
    
    init(provider: JokeRepository, mockProvider: JokeRepository) {
        self.provider = provider
        self.mockProvider = mockProvider
    }
    
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        provider.fetchJokes(amount: amount, completion: completion)
    }
    
    func fetchMockJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        mockProvider.fetchJokes(amount: amount, completion: completion)
    }
}
