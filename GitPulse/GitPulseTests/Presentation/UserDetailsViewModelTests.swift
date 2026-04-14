//
//  UserDetailsViewModelTests.swift
//  GitPulseTests
//
//  Equivalent to Android `UserDetailsViewModelTest`.
//

import XCTest
import Combine
@testable import GitPulse

@MainActor
final class UserDetailsViewModelTests: XCTestCase {

    private var mockRepository: MockUserRepository!
    private var useCase: GetUserDetailsUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        useCase = GetUserDetailsUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    /// Equivalent to Android: `getUserDetails is success`.
    func testInit_withSuccessfulFetch_updatesStateWithFormattedValues() async {
        let expected = UserDetailsModel(
            username: "mojombo",
            avatarUrl: "https://avatar",
            country: "US",
            followers: 100,
            following: 50,
            url: "https://github.com/mojombo"
        )
        mockRepository.getUserDetailsResult = .success(expected)

        let viewModel = UserDetailsViewModel(
            username: "mojombo",
            avatarUrl: "https://avatar",
            url: "https://github.com/mojombo",
            getUserDetailsUseCase: useCase
        )

        let stateExpectation = expectation(description: "state updated with fetched details")
        viewModel.statePublisher
            .dropFirst() // skip replayed initial state
            .sink { state in
                if state.country == "US" {
                    XCTAssertEqual(state.username, "mojombo")
                    XCTAssertEqual(state.avatarUrl, "https://avatar")
                    XCTAssertEqual(state.followers, "100+")
                    XCTAssertEqual(state.following, "50+")
                    XCTAssertEqual(state.url, "https://github.com/mojombo")
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [stateExpectation], timeout: 2)
    }

    /// Equivalent to Android: `getUserDetails is failure`.
    func testInit_withFailedFetch_publishesError() async {
        mockRepository.getUserDetailsResult = .failure(AppError.noConnection)

        let viewModel = UserDetailsViewModel(
            username: "mojombo",
            getUserDetailsUseCase: useCase
        )

        let errorExpectation = expectation(description: "error published")
        viewModel.errorPublisher
            .sink { errorState in
                if errorState.hasError {
                    XCTAssertTrue(errorState.isVisible)
                    XCTAssertFalse(errorState.message.isEmpty)
                    errorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [errorExpectation], timeout: 2)
    }

    /// Initial state carries navigation arguments before fetch completes.
    /// NOTE: async so XCTest hops onto MainActor before invoking.
    func testInit_setsInitialStateFromArguments() async {
        mockRepository.getUserDetailsResult = .success(UserDetailsModel())

        let viewModel = UserDetailsViewModel(
            username: "test",
            avatarUrl: "https://avatar",
            url: "https://url",
            getUserDetailsUseCase: useCase
        )

        XCTAssertEqual(viewModel.state.username, "test")
        XCTAssertEqual(viewModel.state.avatarUrl, "https://avatar")
        XCTAssertEqual(viewModel.state.url, "https://url")
    }
}
