import Foundation

class FetchJokesUseCase {
    private let provider: JokeProvider
    private let mockProvider: JokeProvider
    private var currentPage = 1
    private let pageSize = 10
    
    init(provider: JokeProvider, mockProvider: JokeProvider) {
        self.provider = provider
        self.mockProvider = mockProvider
    }
    
    func reset() {
        currentPage = 1
    }
    
    func loadJokes(loadMore: Bool = false, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        if !loadMore {
            currentPage = 1
        }
        let page = currentPage
        provider.fetchJokes(amount: pageSize, page: page) { [weak self] result in
            switch result {
            case .success(let jokes):
                if !jokes.isEmpty {
                    if loadMore { self?.currentPage += 1 }
                    else { self?.currentPage = 2 }
                    completion(.success(jokes))
                } else {
                    // If no jokes, try mock provider
                    self?.fetchMockJokes(loadMore: loadMore, completion: completion)
                }
            case .failure:
                // On error, fallback to mock provider
                self?.fetchMockJokes(loadMore: loadMore, completion: completion)
            }
        }
    }
    
    private func fetchMockJokes(loadMore: Bool, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        let page = currentPage
        mockProvider.fetchJokes(amount: pageSize, page: page) { [weak self] result in
            switch result {
            case .success(let jokes):
                if loadMore { self?.currentPage += 1 }
                else { self?.currentPage = 2 }
                completion(.success(jokes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
