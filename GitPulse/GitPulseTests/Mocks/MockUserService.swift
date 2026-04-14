//
//  MockUserService.swift
//  GitPulseTests
//

import Foundation
@testable import GitPulse

// `UserServiceProtocol` requires `Sendable`. Result properties are set only
// before the async consumer runs, so `@unchecked` is safe in test contexts.
final class MockUserService: UserServiceProtocol, @unchecked Sendable {

    var getUsersResult: Result<[UserResponse], Error> = .success([])
    var getUserDetailsResult: Result<UserDetailsResponse, Error> = .success(
        UserDetailsResponse(
            id: nil, login: nil, avatarUrl: nil, htmlUrl: nil,
            location: nil, followers: nil, following: nil,
            bio: nil, blog: nil, name: nil
        )
    )

    func getUsers(perPage: Int, since: Int) async throws -> [UserResponse] {
        try getUsersResult.get()
    }

    func getUserDetails(username: String) async throws -> UserDetailsResponse {
        try getUserDetailsResult.get()
    }
}
