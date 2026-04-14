//
//  AppCoordinator.swift
//  GitPulse
//

import UIKit

/// Root coordinator — equivalent to Android's `MainNavHost`.
///
/// Android declares routes up front:
///   NavHost(startDestination = UserListDestination) {
///     composable<UserListDestination> { UserListScreen(navController) }
///     composable<UserDetailsDestination> { UserDetailsScreen(navController) }
///   }
///
/// iOS builds screens on demand (imperative). `start()` installs the user list;
/// `showUserDetails` pushes the details VC; `handleDeepLink` routes external URLs.
@MainActor
final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start

    /// Equivalent to: `NavHost(startDestination = UserListDestination)`.
    func start() {
        showUserList()
    }

    // MARK: - Navigation

    /// Install the user list as root — equivalent to `composable<UserListDestination>`.
    private func showUserList() {
        let viewModel = UserListViewModel()
        let viewController = UserListViewController(viewModel: viewModel)
        viewController.coordinatorDelegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    /// Push user details — equivalent to `navController.navigate(user.toUserDetailsDestination())`.
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
    /// Android equivalent:
    ///   navDeepLink<UserListDestination>(DeepLinks.USER_LIST_PATH)       // gitpulse://users
    ///   navDeepLink<UserDetailsDestination>(DeepLinks.USER_DETAILS_PATH) // gitpulse://users/{username}
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
