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
    
    init(fetchJokesUseCase: FetchJokesUseCase) {
        self.fetchJokesUseCase = fetchJokesUseCase
    }
    
    func loadJokes(loadMore: Bool = false) {
        if isLoading { return }
        isLoading = true
        onUpdate?()
        error = nil
        if !loadMore {
            jokes = []
            currentPage = 1
        }
        fetchJokesUseCase.fetchJokes(amount: pageSize) { [weak self] result in
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
                        self.currentPage = 2
                    }
                case .failure(let error):
                    self.error = error
                }
                self.onUpdate?()
            }
        }
    }
}
