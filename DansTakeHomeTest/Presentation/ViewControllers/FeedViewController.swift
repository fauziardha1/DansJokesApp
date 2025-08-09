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
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No jokes available.\nPlease check your connection or try again later."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Initially hidden
        return label
    }()
    private let reloadButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.clockwise")
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = "Reload"
        return button
    }()
    
    private var mockSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.onTintColor = .systemGreen
        sw.accessibilityLabel = "Use Mock Data"
        return sw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feed"
        setupTableView()
        setupActivityIndicator()
        bindViewModel()
        view.bringSubviewToFront(activityIndicator)
        viewModel.loadJokes()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JokeCell.self, forCellReuseIdentifier: JokeCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(reloadButton)
        view.addSubview(mockSwitch)
        setupMockSwitch()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reloadButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 16),
            reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
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
            DispatchQueue.main.async {
                if self.viewModel.isLoading {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.isHidden = false
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                if !self.viewModel.isLoading && self.viewModel.jokes.isEmpty {
                    self.emptyStateLabel.isHidden = false
                    self.reloadButton.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.emptyStateLabel.isHidden = true
                    self.reloadButton.isHidden = true
                    self.tableView.isHidden = false
                }
                self.tableView.reloadData()
                if let error = self.viewModel.error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription + "\n\n We'll Please check your connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                        self.viewModel.loadJokes()
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func reloadButtonTapped() {
        viewModel.loadJokes()
    }
    
    private func setupMockSwitch() {
        mockSwitch.addTarget(self, action: #selector(mockSwitchChanged), for: .valueChanged)
        let switchBarItem = UIBarButtonItem(customView: mockSwitch)
        navigationItem.rightBarButtonItem = switchBarItem
    }
    
    @objc private func mockSwitchChanged() {
        viewModel.isUsingMockDataOnly = mockSwitch.isOn
        bookmarkViewModel.removeAllBookmarks()
        viewModel.loadJokes()
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
