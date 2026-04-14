//
//  UserRepositoryProtocol.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Combine
import Foundation

/// Repository protocol for user data operations.
///
/// Pagination is handled at the repository level via individual page fetches
/// rather than a streaming paging source, giving the ViewModel explicit control
/// over when each page loads.
protocol UserRepositoryProtocol {

    /// Fetch a page of users starting after `since` ID.
    /// - Parameters:
    ///   - perPage: Number of users per page (default 20)
    ///   - since: The user ID to start after (0 for first page)
    /// - Returns: Publisher emitting array of users for the requested page
    func getUsers(perPage: Int, since: Int) -> AnyPublisher<[UserModel], Error>

    /// Fetch detailed info for a specific user.
    func getUserDetails(username: String) -> AnyPublisher<UserDetailsModel, Error>

    /// Get cached users from local storage.
    func getCachedUsers() -> AnyPublisher<[UserModel], Error>

    /// Save users to local cache.
    func saveUsers(_ users: [UserModel], clearExisting: Bool) -> AnyPublisher<Void, Error>

    /// Get last update timestamp.
    func getLastUpdatedTimestamp() -> AnyPublisher<TimeInterval, Error>

    /// Set last update timestamp.
    func setLastUpdatedTimestamp(_ timestamp: TimeInterval) -> AnyPublisher<Void, Error>
}
