import Foundation

// Repository implementation for Joke
class JokeRepositoryImpl: JokeRepository {
    private let apiService: JokeAPIService
    
    init(apiService: JokeAPIService) {
        self.apiService = apiService
    }
    
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        apiService.fetchJokes(amount: amount) { result in
            switch result {
            case .success(let dtos):
                let entities = dtos.map { dto in
                    JokeEntity(
                        id: String(dto.id),
                        category: dto.category,
                        type: dto.type,
                        joke: dto.joke,
                        setup: dto.setup,
                        delivery: dto.delivery,
                        author: nil, // Not available in API
                        imageUrl: nil // Not available in API
                    )
                }
                completion(.success(entities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
