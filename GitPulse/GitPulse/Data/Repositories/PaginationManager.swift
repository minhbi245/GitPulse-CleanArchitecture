//
//  PaginationManager.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Combine
import Foundation

/// Manages pagination state and offline-first loading strategy.
///
/// Provides three explicit operations:
/// - `loadInitial()` — load from cache first, then refresh if stale
/// - `refresh()`     — clear cache, fetch first page from network
/// - `loadNextPage()` — fetch next page using last user ID
final class PaginationManager: Sendable {

    // MARK: - Dependencies

    private let getUserPagingUseCase: GetUserPagingUseCase
    private let localDataSource: UserLocalDataSourceProtocol
    private let preferencesStore: PreferencesStoreProtocol

    // MARK: - State

    /// Current list of users — UI observes this.
    @MainActor let usersSubject = CurrentValueSubject<[UserModel], Never>([])

    /// Loading state for UI.
    @MainActor let loadingSubject = CurrentValueSubject<PaginationLoadState, Never>(.idle)

    /// Whether more pages are available — restored from PreferencesStore so
    /// cold launches resume the correct state.
    @MainActor private(set) var hasMorePages: Bool

    /// Last user ID for append queries — persisted across cold launches.
    @MainActor private var lastUserId: Int

    /// Prevent concurrent loads.
    @MainActor private var isLoading = false

    // MARK: - Constants

    static let pageSize = 20

    /// Cache validity window — 1 hour in seconds.
    static let cacheTimeout: TimeInterval = 3600

    // MARK: - Init

    init(
        getUserPagingUseCase: GetUserPagingUseCase,
        localDataSource: UserLocalDataSourceProtocol,
        preferencesStore: PreferencesStoreProtocol
    ) {
        self.getUserPagingUseCase = getUserPagingUseCase
        self.localDataSource = localDataSource
        self.preferencesStore = preferencesStore
        // Restore pagination state from persistent store.
        self.lastUserId = preferencesStore.getLastUserListCursor()
        self.hasMorePages = preferencesStore.getHasMoreUsers()
    }

    // MARK: - Public API

    /// Returns true if the cache is still within the validity window.
    @MainActor func isCacheFresh() -> Bool {
        let lastUpdated = preferencesStore.getLastUpdatedUserList()
        let elapsed = Date().timeIntervalSince1970 - lastUpdated
        return elapsed <= Self.cacheTimeout
    }

    /// Initial load — loads from cache first, then refreshes if stale.
    @MainActor func loadInitial() async {
        // Always load cached data first (offline-first).
        loadCachedUsers()

        if !isCacheFresh() {
            await refresh()
        }
    }

    /// REFRESH — clear cache, fetch first page via the use case.
    @MainActor func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        hasMorePages = true
        lastUserId = 0
        loadingSubject.send(.refreshing)

        do {
            let models = try await getUserPagingUseCase(
                perPage: Self.pageSize,
                since: 0
            )

            let localUsers = UserResponseMapper.mapToLocalList(models)
            try localDataSource.upsertAndDeleteAll(needToDelete: true, users: localUsers)

            preferencesStore.setLastUpdatedUserList(Date().timeIntervalSince1970)
            hasMorePages = models.count >= Self.pageSize
            preferencesStore.setHasMoreUsers(hasMorePages)

            // Reload from cache to get the canonical ordered list.
            loadCachedUsers()
            loadingSubject.send(.idle)
        } catch {
            loadingSubject.send(.error(error))
        }
    }

    /// APPEND — fetch next page using last user ID.
    @MainActor func loadNextPage() async {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        defer { isLoading = false }

        loadingSubject.send(.loadingMore)

        do {
            let models = try await getUserPagingUseCase(
                perPage: Self.pageSize,
                since: lastUserId
            )

            let localUsers = UserResponseMapper.mapToLocalList(models)
            try localDataSource.upsertAndDeleteAll(needToDelete: false, users: localUsers)

            hasMorePages = models.count >= Self.pageSize
            preferencesStore.setHasMoreUsers(hasMorePages)
            loadCachedUsers()
            loadingSubject.send(.idle)
        } catch {
            loadingSubject.send(.error(error))
        }
    }

    // MARK: - Private

    @MainActor private func loadCachedUsers() {
        do {
            let entities = try localDataSource.fetchAll()
            let models = UserResponseMapper.mapToDomainList(entities)
            if let lastUser = models.last {
                lastUserId = lastUser.id
                preferencesStore.setLastUserListCursor(lastUser.id)
            }
            usersSubject.send(models)
        } catch {
            print("[PaginationManager] Cache read error: \(error.localizedDescription)")
        }
    }
}

/// Pagination loading states.
enum PaginationLoadState: Equatable {
    case idle
    case refreshing
    case loadingMore
    case error(Error)

    static func == (lhs: PaginationLoadState, rhs: PaginationLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.refreshing, .refreshing), (.loadingMore, .loadingMore):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
