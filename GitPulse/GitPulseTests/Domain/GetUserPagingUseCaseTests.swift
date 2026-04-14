//
//  GetUserPagingUseCaseTests.swift
//  GitPulseTests
//
//  Equivalent to Android `GetUserPagingUseCaseTest`.
//

import XCTest
import Combine
@testable import GitPulse

final class GetUserPagingUseCaseTests: XCTestCase {

    private var mockRepository: MockUserRepository!
    private var useCase: GetUserPagingUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        useCase = GetUserPagingUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    func testCallAsFunction_delegatesToRepositoryWithPassedArgs() {
        let users = [UserModel(id: 1, username: "user1")]
        mockRepository.getUsersResult = .success(users)
        let expectation = expectation(description: "getUsers emits")

        var received: [UserModel] = []
        useCase(perPage: 20, since: 0)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { value in
                    received = value
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(received, users)
        XCTAssertEqual(mockRepository.getUsersCallCount, 1)
        XCTAssertEqual(mockRepository.lastGetUsersPerPage, 20)
        XCTAssertEqual(mockRepository.lastGetUsersSince, 0)
    }
}
