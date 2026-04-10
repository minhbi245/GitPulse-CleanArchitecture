//
//  DataContainer.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Factory
import Foundation

/// DI registrations for the data/network layer.
/// Maps from: Android `RemoteModule.kt` + `ProvidersModule.kt`
extension Container {

    /// Equivalent to @Provides @Singleton fun provideOkHttpClient()
    var apiClient: Factory<APIClient> {
        self { APIClient() }.singleton
    }

    /// Equivalent to @Provides @Singleton fun provideUserService(retrofit)
    var userService: Factory<UserServiceProtocol> {
        self { UserService(apiClient: self.apiClient()) }.singleton
    }
}
