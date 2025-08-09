import UIKit

class FeedViewController: UIViewController {
    var viewModel: FeedViewModel!
    var bookmarkViewModel: BookmarkViewModel! // Injected from HomeViewController
    private let tableView = UITableView()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black // Set the indicator color to dark
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        title = "Feed"
        setupTableView()
        setupActivityIndicator()
        bindViewModel()
        // Ensure activity indicator is visible above table view
        view.bringSubviewToFront(activityIndicator)
        viewModel.loadJokes()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JokeCell.self, forCellReuseIdentifier: JokeCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            // Move activity indicator visibility update to main thread
            DispatchQueue.main.async {
                if self.viewModel.isLoading {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.isHidden = false
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                self.tableView.reloadData()
                if let error = self.viewModel.error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription + "\n\n We'll show you mock data till we have good internet connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                        self.viewModel.loadJokes()
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JokeCell.identifier, for: indexPath) as? JokeCell else {
            return UITableViewCell()
        }
        let joke = viewModel.jokes[indexPath.row]
        let isBookmarked = bookmarkViewModel.bookmarks.contains(where: { $0.id == joke.id })
        cell.configure(with: joke, isBookmarked: isBookmarked) { [weak self] in
            guard let self = self else { return }
            if let _ = self.bookmarkViewModel.bookmarks.firstIndex(where: { $0.id == joke.id }) {
                self.bookmarkViewModel.removeBookmark(joke)
            } else {
                self.bookmarkViewModel.addBookmark(joke)
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    // set height cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight * 2 {
            viewModel.loadJokes(loadMore: true)
        }
    }
}
