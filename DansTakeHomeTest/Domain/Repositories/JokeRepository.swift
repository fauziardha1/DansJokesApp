// Protocol for Joke Repository
protocol JokeRepository {
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeEntity], Error>) -> Void)
}