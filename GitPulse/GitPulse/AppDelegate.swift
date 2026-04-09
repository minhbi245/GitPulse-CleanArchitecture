//
//  AppDelegate.swift
//  GitPulse
//
//  Created by Leo Nguyen on 9/4/26.
//

import UIKit

/// iOS equivalent of Android's Application class (App.kt with @HiltAndroidApp).
/// Core Data stack is NOT here — it will live in CoreDataManager (Phase 04),
/// following the same separation of concerns as Android where Room setup
/// is in a dedicated DatabaseModule, not the Application class.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
