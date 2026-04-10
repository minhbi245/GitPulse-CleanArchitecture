import Combine

/// Use case for fetching user detail information.
/// Maps from: Android `GetUserDetailsUseCase.kt`
final class GetUserDetailsUseCase {

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetch details for a specific user by username.
    /// - Parameter username: GitHub username
    func callAsFunction(username: String) -> AnyPublisher<UserDetailsModel, Error> {
        return repository.getUserDetails(username: username)
    }
}
