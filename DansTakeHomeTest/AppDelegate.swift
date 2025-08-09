//
//  AppDelegate.swift
//  DansTakeHomeTest
//
//  Created by Fauzi Arda on 09/08/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
     var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = HomeViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

