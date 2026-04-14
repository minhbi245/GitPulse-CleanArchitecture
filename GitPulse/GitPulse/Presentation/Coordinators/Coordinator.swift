//
//  Coordinator.swift
//  GitPulse
//

import UIKit

/// Base Coordinator protocol — decouples navigation logic from view controllers.
///
/// Mirrors the role of Android's `NavHostController`: owns a nav stack, decides
/// which screen to show next, and acts as the single source of truth for routing.
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
