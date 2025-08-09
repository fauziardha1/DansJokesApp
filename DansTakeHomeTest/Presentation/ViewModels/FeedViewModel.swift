import Foundation

// ViewModel for Feed (Joke List)
class FeedViewModel {
    private let fetchJokesUseCase: FetchJokesUseCase
    private(set) var jokes: [JokeEntity] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    var onUpdate: (() -> Void)?
    
    private var currentPage = 1
    private let pageSize = 10
    private var allMockJokes: [JokeEntity] = []
    
    init(fetchJokesUseCase: FetchJokesUseCase) {
        self.fetchJokesUseCase = fetchJokesUseCase
    }
    
    private func generateMockJokes(count: Int) -> [JokeEntity] {
        var jokes: [JokeEntity] = []
        for i in 1...count {
            jokes.append(JokeEntity(
                id: "mock\(i)",
                category: "MockCategory",
                type: "twopart",
                joke: nil,
                setup: "Mock setup #\(i)",
                delivery: "Mock delivery #\(i)",
                author: nil,
                imageUrl: nil
            ))
        }
        return jokes
    }
    
    func loadJokes(loadMore: Bool = false) {
        if isLoading { return }
        isLoading = true
        //show loading
        onUpdate?()
        error = nil
        if !loadMore {
            jokes = []
            currentPage = 1
        }
        fetchJokesUseCase.execute(amount: pageSize) { [weak self] result in
            self?.onUpdate?()
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let newJokes):
                    if loadMore {
                        self.jokes.append(contentsOf: newJokes)
                        self.currentPage += 1
                    } else {
                        self.jokes = newJokes
                    }
                case .failure(let error):
                    self.error = error
                    // Provide paginated mock data on error
                    if self.allMockJokes.isEmpty {
                        self.allMockJokes = self.generateMockJokes(count: 100)
                    }
                    let start = (self.currentPage - 1) * self.pageSize
                    let end = min(start + self.pageSize, self.allMockJokes.count)
                    let nextJokes = Array(self.allMockJokes[start..<end])
                    if loadMore {
                        self.jokes.append(contentsOf: nextJokes)
                        self.currentPage += 1
                    } else {
                        self.jokes = nextJokes
                    }
                }
                self.onUpdate?()
            }
        }
    }
    
    private func getMockJokes() -> [JokeEntity] {
        // Deprecated: use paginated mock in loadJokes
        return []
    }
}
