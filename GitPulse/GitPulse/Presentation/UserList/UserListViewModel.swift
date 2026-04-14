//
//  UserListViewModel.swift
//  GitPulse
//

import Combine
import Factory
import Foundation

/// UI state for the user list screen — equivalent to Android `UserListUiState`.
struct UserListUiState: Equatable {
    var isRefreshing: Bool = false
}

/// One-shot navigation events — equivalent to Android sealed event class.
enum UserListEvent: Equatable {
    case navigateToDetails(username: String, avatarUrl: String, url: String)
}

/// ViewModel for the user list screen.
///
/// Maps from: Android `UserListViewModel.kt` (28 lines because Paging3 hides the work).
/// iOS version is larger because we orchestrate `PaginationManager` manually.
@MainActor
final class UserListViewModel: BaseViewModel<UserListUiState, UserListEvent> {

    // MARK: - Dependencies

    private let paginationManager: PaginationManager

    // MARK: - Published State

    /// User list — equivalent to `val userPaging = getUserPagingUseCase().cachedIn(viewModelScope)`.
    @Published private(set) var users: [UserModel] = []

    /// Pagination load state for the append (next page) lane.
    @Published private(set) var paginationState: PaginationLoadState = .idle

    /// Whether more pages are available — surfaced for the VC to gate `loadNextPage`.
    var hasMorePages: Bool {
        paginationManager.hasMorePages
    }

    // MARK: - Init

    init(paginationManager: PaginationManager) {
        self.paginationManager = paginationManager
        super.init(initialState: UserListUiState())
        observePaginationManager()
    }

    /// Convenience initializer using the Factory DI container.
    /// Equivalent to `@HiltViewModel @Inject constructor(getUserPagingUseCase)`.
    convenience init() {
        self.init(paginationManager: Container.shared.paginationManager())
    }

    // MARK: - Actions

    /// Initial data load — call from `viewDidLoad`.
    func loadInitialData() {
        performTask(showLoading: true) { [weak self] in
            await self?.paginationManager.loadInitial()
        }
    }

    /// Pull-to-refresh — equivalent to `pagingItems.refresh() + setRefreshing(true)`.
    /// Uses an explicit `Task` so the `defer` block still clears `isRefreshing`
    /// if the task is cancelled mid-flight (e.g., VC dismissal).
    func refresh() {
        updateState { var s = $0; s.isRefreshing = true; return s }
        Task { [weak self] in
            defer {
                self?.updateState { var s = $0; s.isRefreshing = false; return s }
            }
            await self?.paginationManager.refresh()
        }
    }

    /// Load next page — called when scrolling near the bottom.
    /// VM-level guard prevents a flood of `Task`s from `scrollViewDidScroll` ticks.
    func loadNextPage() {
        guard hasMorePages, paginationState != .loadingMore else { return }
        if case .error = paginationState { return }
        performTask { [weak self] in
            await self?.paginationManager.loadNextPage()
        }
    }

    /// Retry append after error — equivalent to `pagingItems.retry()`.
    func retryLoadNextPage() {
        loadNextPage()
    }

    /// Navigate to user details — equivalent to `navController.navigate(user.toUserDetailsDestination())`.
    func selectUser(_ user: UserModel) {
        sendEvent(.navigateToDetails(
            username: user.username,
            avatarUrl: user.avatarUrl,
            url: user.url
        ))
    }

    // MARK: - Override

    /// Suppress the global loading overlay while a pull-to-refresh is in flight.
    /// Equivalent to Android override that bypasses `super.setLoading` when refreshing.
    override func setLoading(_ loading: Bool) {
        if !state.isRefreshing {
            super.setLoading(loading)
        }
    }

    // MARK: - Private

    private func observePaginationManager() {
        paginationManager.usersSubject
            .sink { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)

        paginationManager.loadingSubject
            .sink { [weak self] loadState in
                guard let self else { return }
                self.paginationState = loadState
                if case .error(let error) = loadState {
                    // Surface alert only for refresh / empty-list errors;
                    // append errors render inline in the footer.
                    if self.state.isRefreshing || self.users.isEmpty {
                        self.showError(error)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
