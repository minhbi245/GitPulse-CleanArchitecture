//
//  GetUserPagingUseCase.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Combine

/// Use case for fetching paginated user list.
/// Maps from: Android `GetUserPagingUseCase.kt`
final class GetUserPagingUseCase {

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetch a page of users.
    /// - Parameters:
    ///   - perPage: Page size (default: 20)
    ///   - since: Last user ID from previous page (0 for first page)
    func callAsFunction(
        perPage: Int = 20,
        since: Int = 0
    ) -> AnyPublisher<[UserModel], Error> {
        return repository.getUsers(perPage: perPage, since: since)
    }
}
