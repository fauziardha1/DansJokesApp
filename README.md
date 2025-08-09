# DansJokesApp

A simple iOS app to display a feed of jokes and manage bookmarks, built as part of a recruitment test.

## Preview

Below are screenshots of the app in action:
<div align="center">
  <img src="https://github.com/user-attachments/assets/c33933a6-990b-49e2-8496-972b721a0a7a" alt="Feed Page" width="300"/>
  <img src="https://github.com/user-attachments/assets/535164c6-0ea2-4c2d-9769-c58e3367b0b0" alt="Bookmarks Page" width="300"/>
</div>

## Features
- Fetches jokes from [JokeAPI](https://v2.jokeapi.dev/joke/Any?amount=10)
- Displays jokes in a scrollable feed with load more (pagination)
- Bookmark/unbookmark jokes from the feed
- View bookmarked jokes in a separate tab
- Handles loading, error, and offline states (shows mock data if network fails)

## Architecture
This project uses **Clean Architecture** combined with **MVVM (Model-View-ViewModel)** pattern for clear separation of concerns and testability.

### Layered Structure
- **Presentation Layer**: UIKit ViewControllers, custom cells, and ViewModels. Handles UI, user interaction, and state binding.
- **Domain Layer**: Entities, UseCases, and Repository Protocols. Contains business logic and app rules.
- **Data Layer**: DTOs, API services, and Repository Implementations. Handles data fetching, mapping, and persistence (in-memory for bookmarks).

### Approach
- **MVVM**: ViewModels expose observable state to the ViewControllers, which update the UI accordingly.
- **Clean Architecture**: Each layer depends only on the layer below it, with clear boundaries and protocols for dependency inversion.
- **Error Handling**: Network errors and timeouts are handled gracefully, with retry options and fallback to mock data.
- **UI**: Built with UIKit, using custom `JokeCell` for displaying jokes and their details.

## Getting Started
1. Clone the repository
2. Open `DansTakeHomeTest.xcodeproj` in Xcode
3. Build and run on Simulator or device

## Folder Structure
- `Data/` - DTOs, API, and repository implementations
- `Domain/` - Entities, use cases, and repository protocols
- `Presentation/` - ViewControllers, ViewModels, and custom cells

## Author
Fauzi Arda

---

Feel free to use this as a reference for Clean Architecture + MVVM in a UIKit iOS project.
