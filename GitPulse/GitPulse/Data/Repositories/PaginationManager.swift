//
//  PaginationManager.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Combine
import Foundation

/// Manages pagination state and offline-first loading strategy.
/// Equivalent to: Android's UserRemoteMediator
///
/// Android RemoteMediator has 3 methods:
/// - initialize() -> check if cache is fresh
/// - load(REFRESH, ...) -> clear cache, fetch first page
/// - load(APPEND, ...) -> fetch next page after last item
///
/// This class provides the same 3 operations as explicit methods.
final class PaginationManager: Sendable {

    // MARK: - Dependencies

    private let userService: UserServiceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let preferencesStore: PreferencesStoreProtocol

    // MARK: - State

    /// Current list of users — UI observes this.
    /// Equivalent to: Pager flow emitting PagingData
    @MainActor let usersSubject = CurrentValueSubject<[UserModel], Never>([])

    /// Loading state for UI
    @MainActor let loadingSubject = CurrentValueSubject<PaginationLoadState, Never>(.idle)

    /// Whether more pages are available.
    /// Equivalent to: MediatorResult.Success(endOfPaginationReached)
    @MainActor private(set) var hasMorePages = true

    /// Last user ID for APPEND queries.
    /// Equivalent to: state.lastItemOrNull()?.id
    @MainActor private var lastUserId: Int = 0

    /// Prevent concurrent loads.
    @MainActor private var isLoading = false

    // MARK: - Constants

    /// Equivalent to: companion object { private const val PAGE_SIZE = 20 }
    static let pageSize = 20

    /// Equivalent to: TimeUnit.MILLISECONDS.convert(1, TimeUnit.HOURS)
    static let cacheTimeout: TimeInterval = 3600 // 1 hour in seconds

    // MARK: - Init

    init(
        userService: UserServiceProtocol,
        localDataSource: UserLocalDataSourceProtocol,
        preferencesStore: PreferencesStoreProtocol
    ) {
        self.userService = userService
        self.localDataSource = localDataSource
        self.preferencesStore = preferencesStore
    }

    // MARK: - Public API

    /// Check if cache is fresh — equivalent to RemoteMediator.initialize()
    ///
    /// Returns true if cache is valid (SKIP_INITIAL_REFRESH)
    /// Returns false if cache is stale (LAUNCH_INITIAL_REFRESH)
    @MainActor func isCacheFresh() -> Bool {
        let lastUpdated = preferencesStore.getLastUpdatedUserList()
        let elapsed = Date().timeIntervalSince1970 - lastUpdated
        return elapsed <= Self.cacheTimeout
    }

    /// Initial load — loads from cache first, then refreshes if stale.
    /// Equivalent to: RemoteMediator.initialize() + possible REFRESH
    @MainActor func loadInitial() async {
        // Always load cached data first (offline-first)
        loadCachedUsers()

        if !isCacheFresh() {
            await refresh()
        }
    }

    /// REFRESH — clear cache, fetch first page from network.
    /// Equivalent to: load(LoadType.REFRESH, ...)
    @MainActor func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        hasMorePages = true
        lastUserId = 0
        loadingSubject.send(.refreshing)

        do {
            let responses = try await userService.getUsers(
                perPage: Self.pageSize,
                since: 0 // INITIAL_SINCE
            )

            let localUsers = UserResponseMapper.mapToLocalList(responses)
            try localDataSource.upsertAndDeleteAll(needToDelete: true, users: localUsers)

            preferencesStore.setLastUpdatedUserList(Date().timeIntervalSince1970)

            hasMorePages = responses.count >= Self.pageSize

            // Reload from cache to get mapped domain models
            loadCachedUsers()
            loadingSubject.send(.idle)
        } catch {
            loadingSubject.send(.error(error))
        }

        isLoading = false
    }

    /// APPEND — fetch next page using last user ID.
    /// Equivalent to: load(LoadType.APPEND, ...)
    @MainActor func loadNextPage() async {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        loadingSubject.send(.loadingMore)

        do {
            let responses = try await userService.getUsers(
                perPage: Self.pageSize,
                since: lastUserId
            )

            let localUsers = UserResponseMapper.mapToLocalList(responses)
            try localDataSource.upsertAndDeleteAll(needToDelete: false, users: localUsers)

            hasMorePages = responses.count >= Self.pageSize
            loadCachedUsers()
            loadingSubject.send(.idle)
        } catch {
            loadingSubject.send(.error(error))
        }

        isLoading = false
    }

    // MARK: - Private

    @MainActor private func loadCachedUsers() {
        do {
            let entities = try localDataSource.fetchAll()
            let models = UserResponseMapper.mapToDomainList(entities)
            if let lastUser = models.last {
                lastUserId = lastUser.id
            }
            usersSubject.send(models)
        } catch {
            print("[PaginationManager] Cache read error: \(error.localizedDescription)")
        }
    }
}

/// Pagination loading states — equivalent to Paging3 LoadState.
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
