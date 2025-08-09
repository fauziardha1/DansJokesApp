import Foundation

/// Provides mock data for testing and offline scenarios.
class MockDataProvider {
    func generateMockJokes(count: Int) -> [JokeEntity] {
        var jokes: [JokeEntity] = []
        for _ in 1...count {
            // get random number
            let i = Int.random(in: 1...1000)
            jokes.append(JokeEntity(
                id: "mock\(i)",
                category: "MockCategory",
                type: "twopart",
                joke: nil,
                setup: "Mock setup #\(i)",
                delivery: "Mock delivery #\(i)"
            ))
        }
        return jokes
    }
}

extension MockDataProvider: JokeRepository {
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void) {
        let jokes = generateMockJokes(count: amount)
        completion(.success(jokes))
    }
}
