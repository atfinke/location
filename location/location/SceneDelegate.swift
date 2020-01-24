//
//  SceneDelegate.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties -
    
    static let activeNotification = Notification.Name("sceneDidBecomeActive")
    static let resignNotification = Notification.Name("sceneWillResignActive")
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate -
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: SceneDelegate.activeNotification, object: nil)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: SceneDelegate.resignNotification, object: nil)
    }
    
}

