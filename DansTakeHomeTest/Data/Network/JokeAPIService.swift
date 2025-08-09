import Foundation

// API Service for Joke API
class JokeAPIService {
    func fetchJokes(amount: Int, completion: @escaping (Result<[JokeDTO], Error>) -> Void) {
        let urlString = "https://v2.jokeapi.dev/joke/Any?amount=\(amount)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let session = URLSession(configuration: config)
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let responseDTO = try JSONDecoder().decode(JokesResponseDTO.self, from: data)
                completion(.success(responseDTO.jokes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
