import Foundation

// ViewModel for Bookmarks
class BookmarkViewModel {
    private(set) var bookmarks: [JokeEntity] = []
    var onUpdate: (() -> Void)?
    
    func addBookmark(_ joke: JokeEntity) {
        if !bookmarks.contains(where: { $0.id == joke.id }) {
            bookmarks.append(joke)
            onUpdate?()
        }
    }
    
    func removeBookmark(_ joke: JokeEntity) {
        bookmarks.removeAll { $0.id == joke.id }
        onUpdate?()
    }
    
    func loadBookmarks() {
        onUpdate?()
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        onUpdate?()
    }
}
