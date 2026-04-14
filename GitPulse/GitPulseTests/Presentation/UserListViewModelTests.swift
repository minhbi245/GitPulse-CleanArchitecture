//
//  UserListViewModelTests.swift
//  GitPulseTests
//
//  Equivalent to Android `UserListViewModelTest`.
//

import XCTest
import Combine
@testable import GitPulse

@MainActor
final class UserListViewModelTests: XCTestCase {

    private func makeViewModel() -> UserListViewModel {
        let manager = PaginationManager(
            userService: MockUserService(),
            localDataSource: MockUserLocalDataSource(),
            preferencesStore: MockPreferencesStore()
        )
        return UserListViewModel(paginationManager: manager)
    }

    // NOTE: Tests are `async` so XCTest hops them onto the MainActor before
    // running. A `@MainActor` class with a sync test method crashes because
    // XCTest invokes it from a background thread without an actor hop.

    /// Equivalent to Android: `setRefreshing updates uiState`.
    func testUpdateState_setRefreshing_updatesState() async {
        let viewModel = makeViewModel()

        viewModel.updateState { var s = $0; s.isRefreshing = true; return s }

        XCTAssertTrue(viewModel.state.isRefreshing)
    }

    /// Equivalent to Android: `setLoading doesn't propagate while refreshing`.
    func testSetLoading_whenRefreshing_isSuppressed() async {
        let viewModel = makeViewModel()
        viewModel.updateState { var s = $0; s.isRefreshing = true; return s }

        viewModel.setLoading(true)

        XCTAssertFalse(viewModel.isLoading)
    }

    /// Equivalent to Android: `setLoading calls super when not refreshing`.
    func testSetLoading_whenNotRefreshing_showsLoading() async {
        let viewModel = makeViewModel()
        viewModel.updateState { var s = $0; s.isRefreshing = false; return s }

        viewModel.setLoading(true)

        XCTAssertTrue(viewModel.isLoading)
    }
}
