//
//  UserDetailsViewModel.swift
//  GitPulse
//

import Combine
import Factory
import Foundation

/// UI state for user details.
struct UserDetailUiState: Equatable {
    var username: String = ""
    var avatarUrl: String = ""
    var country: String = ""
    var followers: String = "0"
    var following: String = "0"
    var url: String = ""
}

/// One-shot events emitted by the details screen.
enum UserDetailsEvent: Equatable {
    case openBlog(url: String)
}

/// ViewModel for the user details screen.
///
/// Receives navigation arguments via `init` (from `UserListViewModel.selectUser` →
/// `UserListEvent.navigateToDetails` routed by the coordinator).
@MainActor
final class UserDetailsViewModel: BaseViewModel<UserDetailUiState, UserDetailsEvent> {

    // MARK: - Dependencies

    private let getUserDetailsUseCase: GetUserDetailsUseCase
    private let username: String

    // MARK: - Init

    init(
        username: String,
        avatarUrl: String = "",
        url: String = "",
        getUserDetailsUseCase: GetUserDetailsUseCase
    ) {
        self.username = username
        self.getUserDetailsUseCase = getUserDetailsUseCase

        super.init(initialState: UserDetailUiState(
            username: username,
            avatarUrl: avatarUrl,
            url: url
        ))

        fetchUserDetails()
    }

    /// Factory DI convenience initializer.
    convenience init(username: String, avatarUrl: String = "", url: String = "") {
        self.init(
            username: username,
            avatarUrl: avatarUrl,
            url: url,
            getUserDetailsUseCase: Container.shared.getUserDetailsUseCase()
        )
    }

    // MARK: - Actions

    /// Emit navigation event — VC opens URL via `UIApplication.shared.open`.
    func openBlog() {
        let url = state.url
        guard !url.isEmpty else { return }
        sendEvent(.openBlog(url: url))
    }

    // MARK: - Private

    private func fetchUserDetails() {
        setLoading(true)
        getUserDetailsUseCase(username: username)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.setLoading(false)
                    if case .failure(let error) = completion {
                        self.showError(error)
                    }
                },
                receiveValue: { [weak self] details in
                    self?.apply(details)
                }
            )
            .store(in: &cancellables)
    }

    private func apply(_ details: UserDetailsModel) {
        setState(UserDetailUiState(
            username: details.username,
            avatarUrl: details.avatarUrl,
            country: details.country,
            followers: "\(details.followers)+",
            following: "\(details.following)+",
            url: details.url
        ))
    }
}
