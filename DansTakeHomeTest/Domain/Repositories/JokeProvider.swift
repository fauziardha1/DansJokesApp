import Foundation

/// Protocol for providing jokes, either from API or mock data
protocol JokeProvider {
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void)
}
