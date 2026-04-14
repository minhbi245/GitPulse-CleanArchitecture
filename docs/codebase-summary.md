# Codebase Summary — GitPulse iOS

~3,300 LOC across 46 Swift source files plus 9 test files. Xcode project at `GitPulse/GitPulse.xcodeproj`. Auto file sync via PBXFileSystemSynchronizedRootGroup (Xcode 15+).

---

## LOC Breakdown by Directory

| Directory | LOC (approx) | Files |
|-----------|-------------|-------|
| `Domain/` | 191 | 6 |
| `Data/Network/` (incl. subdirs) | 520 | 7 |
| `Data/Persistence/` (incl. Entities) | 312 | 5 |
| `Data/Repositories/` (incl. Mappers) | 403 | 4 |
| `Data/DI/` | 78 | 1 |
| `Presentation/Base/` | 300 | 5 |
| `Presentation/Coordinators/` | 130 | 2 |
| `Presentation/UserList/` (incl. Components) | 629 | 3 |
| `Presentation/UserDetails/` (incl. Components) | 575 | 6 |
| `Presentation/Theme/` | 85 | 2 |
| `DI/` | 34 | 1 |
| `Extensions/` | 36 | 1 |
| `App/` (AppDelegate, SceneDelegate) | ~109 | 2 |
| **Total** | **~3,302** | **~46** |

Test files: `GitPulseTests/` — Domain (2), Data (3), Presentation (2), Mocks (4) = 9 files, 20 unit tests.

---

## File Tour

### Domain Layer (`GitPulse/GitPulse/Domain/`)

Pure Swift — no UIKit, no Combine imports, no framework dependencies.

| File | Responsibility |
|------|---------------|
| `Models/UserModel.swift` | List-view domain model: `id`, `username`, `avatarUrl`, `url`. Conforms to `Hashable`, `Identifiable`, `Sendable`. |
| `Models/UserDetailsModel.swift` | Detail-view domain model: adds `country`, `followers`, `following`. Conforms to `Equatable`. |
| `Errors/AppError.swift` | `enum AppError: LocalizedError, Equatable` — cases: `.api(code:message:)`, `.noConnection`, `.unauthorized`, `.unknown(String)`. |
| `Repositories/UserRepositoryProtocol.swift` | Protocol defining all data operations. Combine-based (`AnyPublisher` returns). |
| `UseCases/GetUserPagingUseCase.swift` | Wraps `repository.getUsers(perPage:since:)`. Callable via `callAsFunction`. |
| `UseCases/GetUserDetailsUseCase.swift` | Wraps `repository.getUserDetails(username:)`. Callable via `callAsFunction`. |

### Data Layer — Networking (`GitPulse/GitPulse/Data/Network/`)

| File | Responsibility |
|------|---------------|
| `APIClient.swift` | URLSession wrapper. `request<T: Decodable>(_ endpoint:) async throws -> T`. Validates HTTP status, decodes JSON. DEBUG logging. |
| `APIEndpoint.swift` | `enum APIEndpoint` — cases `.getUsers(perPage:since:)` and `.getUserDetails(username:)`. Builds `URLRequest` via `asURLRequest()`. Base URL: `https://api.github.com`. |
| `SSLPinningDelegate.swift` | `URLSessionDelegate` for TLS challenge. Extracts leaf cert public key, SHA256 hashes it, compares to `pinnedDomains` dict. Debug: logs mismatch, allows. Release: cancels. |
| `NetworkErrorMapper.swift` | Maps HTTP status codes and `Error` instances to `AppError`. |
| `Services/UserService.swift` | `UserServiceProtocol` + `UserService` impl. Two async methods: `getUsers(perPage:since:)`, `getUserDetails(username:)`. |
| `Responses/UserResponse.swift` | DTO for list endpoint. Optional fields decoded from JSON. |
| `Responses/UserDetailsResponse.swift` | DTO for detail endpoint. Optional fields decoded from JSON. |
| `Responses/ErrorResponse.swift` | DTO for API error body. |

### Data Layer — Persistence (`GitPulse/GitPulse/Data/Persistence/`)

| File | Responsibility |
|------|---------------|
| `CoreDataManager.swift` | Singleton. `NSPersistentContainer("GitPulse")`. Configures `NSFileProtectionComplete`. Exposes `viewContext` and `newBackgroundContext()`. Saves on `sceneDidEnterBackground`. |
| `UserLocalDataSource.swift` | `UserLocalDataSourceProtocol` + impl. `fetchAll()` returns `[UserEntity]`. `upsertAndDeleteAll(needToDelete:users:)` writes a page. |
| `PreferencesStore.swift` | `PreferencesStoreProtocol` + impl via `KeychainAccess`. Stores cache timestamp string under key `"last_updated_user_list"`. Accessibility: `.whenUnlockedThisDeviceOnly`. |
| `Entities/UserEntity+CoreDataClass.swift` | Core Data `NSManagedObject` subclass. |
| `Entities/UserEntity+CoreDataProperties.swift` | Core Data generated properties: `id`, `username`, `avatarUrl`, `url`. |

### Data Layer — Repositories (`GitPulse/GitPulse/Data/Repositories/`)

| File | Responsibility |
|------|---------------|
| `UserRepositoryImpl.swift` | Implements `UserRepositoryProtocol`. Bridges `async throws` service calls into `AnyPublisher` via `Future`. Delegates cache reads/writes to `UserLocalDataSource`. |
| `PaginationManager.swift` | Offline-first pagination state machine. Exposes `usersSubject: CurrentValueSubject<[UserModel], Never>` and `loadingSubject: CurrentValueSubject<PaginationLoadState, Never>`. Methods: `loadInitial()`, `refresh()`, `loadNextPage()`. |
| `Mappers/UserResponseMapper.swift` | Maps `UserResponse` → `UserModel` and `UserEntity` → `UserModel`. |
| `Mappers/UserDetailsResponseMapper.swift` | Maps `UserDetailsResponse` → `UserDetailsModel`. |

### Data DI (`GitPulse/GitPulse/Data/DI/DataContainer.swift`)

`extension Container` registering: `apiClient`, `userService`, `coreDataManager`, `userLocalDataSource`, `preferencesStore`, `paginationManager`, `userRepository`, `getUserPagingUseCase`, `getUserDetailsUseCase`. All singletons except use cases (transient).

### Presentation — Base (`GitPulse/GitPulse/Presentation/Base/`)

| File | Responsibility |
|------|---------------|
| `BaseViewModel.swift` | Generic `BaseViewModel<UiState, Event>`. Manages `statePublisher`, `errorPublisher`, `isLoadingPublisher`, `eventPublisher` via Combine subjects. `performTask(showLoading:onError:task:)` for safe async work. |
| `ErrorState.swift` | `enum ErrorState` — `.hidden` / `.visible(title:message:)`. `ErrorStateMapper.map(Error)` converts `AppError` to display state. |
| `LoadingView.swift` | `UIActivityIndicatorView`-based overlay. `show(in:)` / `hide()`. |
| `ErrorAlertHelper.swift` | Presents `UIAlertController` for error states. |
| `ViewModelBindingHelper.swift` | Utilities for subscribing ViewModel publishers to VC lifecycle. |

### Presentation — Coordinators (`GitPulse/GitPulse/Presentation/Coordinators/`)

| File | Responsibility |
|------|---------------|
| `Coordinator.swift` | `protocol Coordinator: AnyObject` — `navigationController`, `childCoordinators`, `start()`. Extensions: `addChild(_:)`, `removeChild(_:)`. |
| `AppCoordinator.swift` | Root coordinator. `start()` installs `UserListViewController`. `showUserDetails(username:avatarUrl:url:)` pushes details. `handleDeepLink(url:)` parses `gitpulse://` URLs. Conforms to `UserListCoordinatorDelegate`. |

### Presentation — UserList (`GitPulse/GitPulse/Presentation/UserList/`)

| File | Responsibility |
|------|---------------|
| `UserListViewModel.swift` | `@MainActor final class` extending `BaseViewModel<UserListUiState, UserListEvent>`. State: `users: [UserModel]`, `paginationState: PaginationLoadState`. Actions: `loadInitialData()`, `refresh()`, `loadNextPage()`, `retryLoadNextPage()`, `selectUser(_:)`. |
| `UserListViewController.swift` | UITableView with diffable data source. Binds ViewModel publishers. Triggers `loadNextPage()` in `scrollViewDidScroll`. Delegates tap to coordinator via `UserListCoordinatorDelegate`. |
| `Components/UserCell.swift` | `UITableViewCell` subclass. Avatar (Kingfisher, 48pt circle), username label, GitHub URL label. SnapKit layout. |
| `Components/LoadMoreFooterView.swift` | `UITableViewHeaderFooterView`. Shows spinner or error + retry button based on `PaginationLoadState`. |

### Presentation — UserDetails (`GitPulse/GitPulse/Presentation/UserDetails/`)

| File | Responsibility |
|------|---------------|
| `UserDetailsViewModel.swift` | Extends `BaseViewModel`. Injects `GetUserDetailsUseCase` via Factory. Calls use case on init. |
| `UserDetailsViewController.swift` | `UIScrollView` + vertical stack. Binds ViewModel state to sub-components. |
| `Components/UserDetailsCardView.swift` | Avatar (96pt), name, login labels. |
| `Components/UserDetailsStatsView.swift` | Followers / following columns with divider. |
| `Components/UserBlogView.swift` | Tappable blog URL row. Opens `SFSafariViewController`. |
| `Components/UserCountryView.swift` | Country text with map pin icon. |

### Presentation — Theme (`GitPulse/GitPulse/Presentation/Theme/`)

| File | Responsibility |
|------|---------------|
| `AppColors.swift` | `enum AppColors` — `primary`, `secondary`, `tertiary` from Asset Catalog (`BrandPrimary`, `BrandSecondary`, `BrandTertiary`). Falls back to system colors. |
| `AppTypography.swift` | `enum AppTypography` — static `UIFont` properties via `UIFont.preferredFont(forTextStyle:)` for Dynamic Type. |

### App Bootstrapping

| File | Responsibility |
|------|---------------|
| `SceneDelegate.swift` | Creates `UIWindow`, `UINavigationController`, `AppCoordinator`. Handles cold-launch and warm deep links. Calls `CoreDataManager.shared.saveContext()` on background. |
| `AppDelegate.swift` | Minimal — scene lifecycle only. |
| `Extensions/BundleExtensions.swift` | Convenience accessors for Bundle info (app version, bundle ID). |

---

## Import Graph (Simplified)

```
Presentation  -->  Domain (models, protocols, errors)
Presentation  -->  Factory (DI injection)
Data          -->  Domain (protocols, models, errors)
Data          -->  Factory (Container extension)
DataContainer -->  Data (concrete types)
AppCoordinator -> Presentation (VCs, VMs)
SceneDelegate -->  AppCoordinator
SceneDelegate -->  Data (CoreDataManager.shared)
Domain        -->  (no external imports)
```

---

## Test Coverage

| Test File | Layer | Tests |
|-----------|-------|-------|
| `Domain/GetUserPagingUseCaseTests.swift` | Domain | 3 |
| `Domain/GetUserDetailsUseCaseTests.swift` | Domain | 2 |
| `Data/UserResponseMapperTests.swift` | Data | 3 |
| `Data/UserDetailsResponseMapperTests.swift` | Data | 3 |
| `Data/NetworkErrorMapperTests.swift` | Data | 3 |
| `Presentation/UserListViewModelTests.swift` | Presentation | 3 |
| `Presentation/UserDetailsViewModelTests.swift` | Presentation | 3 |
| **Total** | | **20** |

Mocks: `MockUserRepository`, `MockUserLocalDataSource`, `MockPreferencesStore`, `MockUserService`.

---

## Related Docs

- [System Architecture](./system-architecture.md)
- [Code Standards](./code-standards.md)
- [Project Overview](./project-overview-pdr.md)
