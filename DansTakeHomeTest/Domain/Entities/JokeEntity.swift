// Joke entity for domain layer
struct JokeEntity: Equatable, Identifiable {
    let id: String
    let category: String
    let type: String
    let joke: String?
    let setup: String?
    let delivery: String?
}
