//
//  UserService.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// Service layer for GitHub User API calls.
protocol UserServiceProtocol: Sendable {
    func getUsers(perPage: Int, since: Int) async throws -> [UserResponse]
    func getUserDetails(username: String) async throws -> UserDetailsResponse
}

final class UserService: UserServiceProtocol {

    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getUsers(perPage: Int, since: Int) async throws -> [UserResponse] {
        try await apiClient.request(.getUsers(perPage: perPage, since: since))
    }

    func getUserDetails(username: String) async throws -> UserDetailsResponse {
        try await apiClient.request(.getUserDetails(username: username))
    }
}
