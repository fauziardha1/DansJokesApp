//
//  TabBarViewController.swift
//  DansTakeHomeTest
//
//  Created by Fauzi Arda on 09/08/25.
//
import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Setup dependencies using DI container
        let diContainer = AppDIContainer()
        let feedViewModel = diContainer.makeFeedViewModel()
        let bookmarkViewModel = diContainer.makeBookmarkViewModel()
        
        // Feed Tab
        let feedVC = FeedViewController()
        feedVC.viewModel = feedViewModel
        feedVC.bookmarkViewModel = bookmarkViewModel // Inject shared bookmarkViewModel
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        // Bookmark Tab
        let bookmarkVC = BookmarkViewController()
        bookmarkVC.viewModel = bookmarkViewModel
        bookmarkVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        
        // Set ViewControllers
        viewControllers = [
            UINavigationController(rootViewController: feedVC),
            UINavigationController(rootViewController: bookmarkVC)
        ]
    }
}
