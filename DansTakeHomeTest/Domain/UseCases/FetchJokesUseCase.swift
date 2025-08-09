// UseCase for fetching jokes
class FetchJokesUseCase {
    private let provider: JokeRepository
    private let mockProvider: JokeRepository
    
    init(provider: JokeRepository, mockProvider: JokeRepository) {
        self.provider = provider
        self.mockProvider = mockProvider
    }
    
    func fetchJokes(amount: Int, useMockData: Bool = false, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        guard useMockData else {
            return provider.fetchJokes(amount: amount, completion: completion)
        }
        mockProvider.fetchJokes(amount: amount, completion: completion)
    }
    
    private func fetchMockJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        mockProvider.fetchJokes(amount: amount, completion: completion)
    }
}
