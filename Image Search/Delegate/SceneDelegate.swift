//
//  SceneDelegate.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let imageLoader: ImageLoaderProtocol = ImageLoader.shared
        let mainViewController = MainPageViewController(imageLoader: imageLoader)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.tintColor = .customPurple
        self.window = window
        window.makeKeyAndVisible()
    }

}
