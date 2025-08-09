// DTO for Joke API response
struct FlagsDTO: Decodable {
    let nsfw: Bool
    let religious: Bool
    let political: Bool
    let racist: Bool
    let sexist: Bool
    let explicit: Bool
}

struct JokeDTO: Decodable {
    let id: Int
    let category: String
    let type: String
    let joke: String?
    let setup: String?
    let delivery: String?
    let flags: FlagsDTO
    let safe: Bool
    let lang: String
}

struct JokesResponseDTO: Decodable {
    let error: Bool
    let amount: Int
    let jokes: [JokeDTO]
}
