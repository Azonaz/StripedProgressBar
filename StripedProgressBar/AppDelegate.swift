//
//  AppDelegate.swift
//  StripedProgressBar
//
//  Created by Админ on 03/07/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = StripedProgressBarViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
