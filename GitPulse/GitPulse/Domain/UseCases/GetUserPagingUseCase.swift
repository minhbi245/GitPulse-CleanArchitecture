//
//  GetUserPagingUseCase.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Combine

/// Use case for fetching a paginated user list.
final class GetUserPagingUseCase {

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetch a page of users (Combine).
    /// - Parameters:
    ///   - perPage: Page size (default: 20)
    ///   - since: Last user ID from previous page (0 for first page)
    func callAsFunction(
        perPage: Int = 20,
        since: Int = 0
    ) -> AnyPublisher<[UserModel], Error> {
        return repository.getUsers(perPage: perPage, since: since)
    }

    /// Fetch a page of users (async/await) — used by `PaginationManager`.
    func callAsFunction(
        perPage: Int = 20,
        since: Int = 0
    ) async throws -> [UserModel] {
        return try await repository.getUsersAsync(perPage: perPage, since: since)
    }
}
