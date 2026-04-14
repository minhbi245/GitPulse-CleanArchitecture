//
//  GetUserDetailsUseCaseTests.swift
//  GitPulseTests
//

import XCTest
import Combine
@testable import GitPulse

final class GetUserDetailsUseCaseTests: XCTestCase {

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

    func testCallAsFunction_delegatesToRepository() {
        let expected = UserDetailsModel(
            username: "mojombo",
            avatarUrl: "https://avatar",
            country: "US",
            followers: 100,
            following: 50,
            url: "https://github.com/mojombo"
        )
        mockRepository.getUserDetailsResult = .success(expected)
        let expectation = expectation(description: "getUserDetails emits")

        var received: UserDetailsModel?
        useCase(username: "mojombo")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { value in
                    received = value
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(received, expected)
        XCTAssertEqual(mockRepository.getUserDetailsCallCount, 1)
        XCTAssertEqual(mockRepository.lastGetDetailsUsername, "mojombo")
    }
}
