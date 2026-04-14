//
//  AppContainer.swift
//  GitPulse
//
//  Factory DI container root. Registrations are added per phase via extensions
//  in the Data and Domain layers.
//
//  Usage in ViewModel:
//    @Injected(\.getUserPagingUseCase) private var useCase
//

import Factory

extension Container {
    // MARK: - Registrations added per phase:
    // Phase 03: Network layer (APIClient, UserService)
    // Phase 04: Persistence layer (CoreDataManager, PreferencesStore)
    // Phase 05: Repositories (UserRepository)
    // Phase 06: Use Cases, ViewModels
}
