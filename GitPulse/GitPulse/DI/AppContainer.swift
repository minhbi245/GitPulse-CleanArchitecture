//
//  AppContainer.swift
//  GitPulse
//
//  iOS equivalent of Android's Hilt DI modules.
//
//  Android Hilt pattern:
//    @Module @InstallIn(SingletonComponent::class)
//    class RemoteModule {
//        @Provides @Singleton
//        fun provideUserService(retrofit: Retrofit): UserService
//    }
//
//  iOS Factory pattern:
//    extension Container {
//        var userService: Factory<UserServiceProtocol> {
//            self { UserServiceImpl() }.singleton
//        }
//    }
//
//  Usage in ViewModel:
//    Android: @Inject constructor(private val useCase: GetUserPagingUseCase)
//    iOS:     @Injected(\.getUserPagingUseCase) private var useCase
//

import Factory

extension Container {
    // MARK: - Registrations added per phase:
    // Phase 03: Network layer (APIClient, UserService)
    // Phase 04: Persistence layer (CoreDataManager, PreferencesStore)
    // Phase 05: Repositories (UserRepository)
    // Phase 06: Use Cases, ViewModels
}
