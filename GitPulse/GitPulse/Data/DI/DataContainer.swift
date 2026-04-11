//
//  DataContainer.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Factory
import Foundation

/// DI registrations for the data layer.
/// Maps from: Android `RemoteModule.kt`, `ProvidersModule.kt`, `DatabaseModule.kt`
extension Container {

    // MARK: - Networking

    /// Equivalent to @Provides @Singleton fun provideOkHttpClient()
    var apiClient: Factory<APIClient> {
        self { APIClient() }.singleton
    }

    /// Equivalent to @Provides @Singleton fun provideUserService(retrofit)
    var userService: Factory<UserServiceProtocol> {
        self { UserService(apiClient: self.apiClient()) }.singleton
    }

    // MARK: - Persistence

    /// Equivalent to @Provides @Singleton fun provideUserDatabase()
    var coreDataManager: Factory<CoreDataManager> {
        self { CoreDataManager.shared }.singleton
    }

    /// Equivalent to @Provides @Singleton fun provideUserDao(userDatabase)
    var userLocalDataSource: Factory<UserLocalDataSourceProtocol> {
        self { UserLocalDataSource(coreDataManager: self.coreDataManager()) }.singleton
    }

    /// Equivalent to @Provides @Singleton fun providePreferencesDataStore()
    var preferencesStore: Factory<PreferencesStoreProtocol> {
        self { PreferencesStore() }.singleton
    }

    // MARK: - Repositories

    /// PaginationManager singleton — equivalent to RemoteMediator injection.
    /// Manages offline-first pagination state for the user list.
    var paginationManager: Factory<PaginationManager> {
        self {
            PaginationManager(
                userService: self.userService(),
                localDataSource: self.userLocalDataSource(),
                preferencesStore: self.preferencesStore()
            )
        }.singleton
    }

    /// Equivalent to: @Binds fun bindUserRepository(impl: UserRepositoryImpl): UserRepository
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
