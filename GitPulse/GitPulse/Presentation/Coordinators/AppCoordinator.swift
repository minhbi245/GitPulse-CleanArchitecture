//
//  AppCoordinator.swift
//  GitPulse
//

import UIKit

/// Root coordinator — owns the navigation stack and wires screens together.
///
/// `start()` installs the user list as root; `showUserDetails` pushes the
/// details VC; `handleDeepLink` routes external URLs.
@MainActor
final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    func start() {
        navigationController.navigationBar.tintColor = AppColors.primary
        showUserList()
    }

    // MARK: - Navigation

    /// Install the user list as the root view controller.
    private func showUserList() {
        let viewModel = UserListViewModel()
        let viewController = UserListViewController(viewModel: viewModel)
        viewController.coordinatorDelegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    /// Push user details onto the navigation stack.
    func showUserDetails(username: String, avatarUrl: String, url: String) {
        let viewModel = UserDetailsViewModel(
            username: username,
            avatarUrl: avatarUrl,
            url: url
        )
        let viewController = UserDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    // MARK: - Deep Links

    /// Parse the incoming URL path and route accordingly.
    ///
    /// Supported routes:
    ///   gitpulse://users         → pop to user list
    ///   gitpulse://users/{name}  → open user details for {name}
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        // `host` is the first segment for `scheme://host/path` URLs like `gitpulse://users/mojombo`.
        var segments: [String] = []
        if let host = components.host, !host.isEmpty {
            segments.append(host)
        }
        segments.append(contentsOf:
            components.path
                .split(separator: "/")
                .map(String.init)
        )

        // Swift arrays don't support `let`-binding patterns, so match manually.
        guard segments.first == "users" else { return }

        if segments.count == 1 {
            navigationController.popToRootViewController(animated: true)
        } else if segments.count == 2 {
            let username = segments[1]
            navigationController.popToRootViewController(animated: false)
            showUserDetails(username: username, avatarUrl: "", url: "")
        }
    }
}

// MARK: - UserListCoordinatorDelegate

/// Routes user-list intents to the coordinator — replaces direct navigation.
protocol UserListCoordinatorDelegate: AnyObject {
    func userListDidSelectUser(username: String, avatarUrl: String, url: String)
}

extension AppCoordinator: UserListCoordinatorDelegate {
    func userListDidSelectUser(username: String, avatarUrl: String, url: String) {
        showUserDetails(username: username, avatarUrl: avatarUrl, url: url)
    }
}
