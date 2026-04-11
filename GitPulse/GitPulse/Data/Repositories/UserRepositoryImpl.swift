//
//  UserRepositoryImpl.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Combine
import Foundation

/// Repository implementation — equivalent to Android's UserRepositoryImpl.
///
/// Android version delegates pagination to Pager+RemoteMediator.
/// iOS version delegates to PaginationManager (our custom equivalent).
final class UserRepositoryImpl: UserRepositoryProtocol {

    private let userService: UserServiceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let preferencesStore: PreferencesStoreProtocol

    /// Lazy PaginationManager — equivalent to RemoteMediator being injected.
    lazy var paginationManager: PaginationManager = {
        PaginationManager(
            userService: userService,
            localDataSource: localDataSource,
            preferencesStore: preferencesStore
        )
    }()

    init(
        userService: UserServiceProtocol,
        localDataSource: UserLocalDataSourceProtocol,
        preferencesStore: PreferencesStoreProtocol
    ) {
        self.userService = userService
        self.localDataSource = localDataSource
        self.preferencesStore = preferencesStore
    }

    // MARK: - UserRepositoryProtocol

    func getUsers(perPage: Int, since: Int) -> AnyPublisher<[UserModel], Error> {
        Future<[UserModel], Error> { [weak self] promise in
            Task {
                do {
                    guard let self else {
                        promise(.failure(AppError.unknown("Repository deallocated")))
                        return
                    }
                    let responses = try await self.userService.getUsers(
                        perPage: perPage, since: since
                    )
                    let models = responses.map { response in
                        UserModel(
                            id: response.id ?? 0,
                            username: response.login ?? "",
                            avatarUrl: response.avatarUrl ?? "",
                            url: response.htmlUrl ?? ""
                        )
                    }
                    promise(.success(models))
                } catch {
                    promise(.failure(NetworkErrorMapper.mapError(error)))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Equivalent to: override fun getUserDetails(username) = flow { emit(userService.getUserDetails(username).toUserDetailsModel()) }
    func getUserDetails(username: String) -> AnyPublisher<UserDetailsModel, Error> {
        Future<UserDetailsModel, Error> { [weak self] promise in
            Task {
                do {
                    guard let self else {
                        promise(.failure(AppError.unknown("Repository deallocated")))
                        return
                    }
                    let response = try await self.userService.getUserDetails(username: username)
                    let model = UserDetailsResponseMapper.mapToDomain(response)
                    promise(.success(model))
                } catch {
                    promise(.failure(NetworkErrorMapper.mapError(error)))
                }
            }
        }.eraseToAnyPublisher()
    }

    func getCachedUsers() -> AnyPublisher<[UserModel], Error> {
        Future<[UserModel], Error> { [weak self] promise in
            do {
                guard let self else {
                    promise(.failure(AppError.unknown("Repository deallocated")))
                    return
                }
                let entities = try self.localDataSource.fetchAll()
                let models = UserResponseMapper.mapToDomainList(entities)
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func saveUsers(_ users: [UserModel], clearExisting: Bool) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            do {
                guard let self else {
                    promise(.failure(AppError.unknown("Repository deallocated")))
                    return
                }
                let tuples = users.map { user in
                    (id: user.id, username: user.username,
                     avatarUrl: user.avatarUrl, url: user.url)
                }
                try self.localDataSource.upsertAndDeleteAll(
                    needToDelete: clearExisting, users: tuples
                )
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func getLastUpdatedTimestamp() -> AnyPublisher<TimeInterval, Error> {
        Just(preferencesStore.getLastUpdatedUserList())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setLastUpdatedTimestamp(_ timestamp: TimeInterval) -> AnyPublisher<Void, Error> {
        preferencesStore.setLastUpdatedUserList(timestamp)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
