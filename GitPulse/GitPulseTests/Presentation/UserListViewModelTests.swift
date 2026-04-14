//
//  UserListViewModelTests.swift
//  GitPulseTests
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

    func testUpdateState_setRefreshing_updatesState() async {
        let viewModel = makeViewModel()

        viewModel.updateState { var s = $0; s.isRefreshing = true; return s }

        XCTAssertTrue(viewModel.state.isRefreshing)
    }

    func testSetLoading_whenRefreshing_isSuppressed() async {
        let viewModel = makeViewModel()
        viewModel.updateState { var s = $0; s.isRefreshing = true; return s }

        viewModel.setLoading(true)

        XCTAssertFalse(viewModel.isLoading)
    }

    func testSetLoading_whenNotRefreshing_showsLoading() async {
        let viewModel = makeViewModel()
        viewModel.updateState { var s = $0; s.isRefreshing = false; return s }

        viewModel.setLoading(true)

        XCTAssertTrue(viewModel.isLoading)
    }
}
