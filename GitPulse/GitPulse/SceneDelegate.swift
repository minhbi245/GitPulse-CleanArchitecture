//
//  SceneDelegate.swift
//  GitPulse
//
//  Created by Leo Nguyen on 9/4/26.
//

import UIKit

/// iOS equivalent of Android's MainActivity.onCreate() + setContent { MainNavHost() }
/// Creates the UIWindow programmatically and sets the root UINavigationController.
/// In Android, the system creates the Activity from the manifest; here we explicitly
/// build the window and attach a rootViewController.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // Temporary root VC — will be replaced by AppCoordinator in Phase 09
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .systemBackground
        rootVC.title = "GitPulse"

        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBar.prefersLargeTitles = true

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}
