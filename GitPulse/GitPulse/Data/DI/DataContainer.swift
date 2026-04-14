//
//  DataContainer.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Factory
import Foundation

/// DI registrations for the data layer.
extension Container {

    // MARK: - Networking

    var apiClient: Factory<APIClient> {
        self { APIClient() }.singleton
    }

    var userService: Factory<UserServiceProtocol> {
        self { UserService(apiClient: self.apiClient()) }.singleton
    }

    // MARK: - Persistence

    var coreDataManager: Factory<CoreDataManager> {
        self { CoreDataManager.shared }.singleton
    }

    var userLocalDataSource: Factory<UserLocalDataSourceProtocol> {
        self { UserLocalDataSource(coreDataManager: self.coreDataManager()) }.singleton
    }

    var preferencesStore: Factory<PreferencesStoreProtocol> {
        self { PreferencesStore() }.singleton
    }

    // MARK: - Repositories

    /// PaginationManager singleton — manages offline-first pagination state for the user list.
    var paginationManager: Factory<PaginationManager> {
        self {
            PaginationManager(
                userService: self.userService(),
                localDataSource: self.userLocalDataSource(),
                preferencesStore: self.preferencesStore()
            )
        }.singleton
    }

    var userRepository: Factory<UserRepositoryProtocol> {
        self {
            UserRepositoryImpl(
                userService: self.userService(),
                localDataSource: self.userLocalDataSource(),
                preferencesStore: self.preferencesStore()
            )
        }.singleton
    }

    // MARK: - Use Cases

    var getUserPagingUseCase: Factory<GetUserPagingUseCase> {
        self { GetUserPagingUseCase(repository: self.userRepository()) }
    }

    var getUserDetailsUseCase: Factory<GetUserDetailsUseCase> {
        self { GetUserDetailsUseCase(repository: self.userRepository()) }
    }
}
