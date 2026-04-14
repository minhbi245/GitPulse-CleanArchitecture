//
//  MockUserRepository.swift
//  GitPulseTests
//
//  Protocol-based mock — configure `*Result` before calling the method under test.
//  Call counts + last-args enable assertion-based verification.
//

import Combine
import Foundation
@testable import GitPulse

final class MockUserRepository: UserRepositoryProtocol {

    var getUsersResult: Result<[UserModel], Error> = .success([])
    var getUserDetailsResult: Result<UserDetailsModel, Error> = .success(UserDetailsModel())
    var getCachedUsersResult: Result<[UserModel], Error> = .success([])
    var saveUsersResult: Result<Void, Error> = .success(())
    var lastUpdatedTimestamp: TimeInterval = 0

    var getUsersCallCount = 0
    var getUserDetailsCallCount = 0
    var lastGetUsersPerPage: Int?
    var lastGetUsersSince: Int?
    var lastGetDetailsUsername: String?

    func getUsers(perPage: Int, since: Int) -> AnyPublisher<[UserModel], Error> {
        getUsersCallCount += 1
        lastGetUsersPerPage = perPage
        lastGetUsersSince = since
        return getUsersResult.publisher.eraseToAnyPublisher()
    }

    func getUserDetails(username: String) -> AnyPublisher<UserDetailsModel, Error> {
        getUserDetailsCallCount += 1
        lastGetDetailsUsername = username
        return getUserDetailsResult.publisher.eraseToAnyPublisher()
    }

    func getCachedUsers() -> AnyPublisher<[UserModel], Error> {
        getCachedUsersResult.publisher.eraseToAnyPublisher()
    }

    func saveUsers(_ users: [UserModel], clearExisting: Bool) -> AnyPublisher<Void, Error> {
        saveUsersResult.publisher.eraseToAnyPublisher()
    }

    func getLastUpdatedTimestamp() -> AnyPublisher<TimeInterval, Error> {
        Just(lastUpdatedTimestamp)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setLastUpdatedTimestamp(_ timestamp: TimeInterval) -> AnyPublisher<Void, Error> {
        lastUpdatedTimestamp = timestamp
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
