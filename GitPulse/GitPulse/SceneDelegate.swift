//
//  SceneDelegate.swift
//  GitPulse
//
//  Created by Leo Nguyen on 9/4/26.
//

import UIKit

/// Builds the window, installs a root `UINavigationController`, and hands off
/// routing to `AppCoordinator`. Deep links are parsed here and forwarded to
/// the coordinator.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let coordinator = AppCoordinator(navigationController: navigationController)
        coordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
        self.appCoordinator = coordinator

        // Cold-launch deep link: app was opened via URL.
        if let urlContext = connectionOptions.urlContexts.first {
            coordinator.handleDeepLink(url: urlContext.url)
        }
    }

    /// Warm deep link — app already running, opened via URL.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appCoordinator?.handleDeepLink(url: url)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}
