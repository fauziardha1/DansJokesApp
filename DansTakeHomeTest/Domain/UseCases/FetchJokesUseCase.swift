// UseCase for fetching jokes
class FetchJokesUseCase {
    private let repository: JokeRepository
    
    init(repository: JokeRepository) {
        self.repository = repository
    }
    
    func execute(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        repository.fetchJokes(amount: amount, completion: completion)
    }
}