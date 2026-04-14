# System Architecture — GitPulse iOS

## Layer Diagram

```
+---------------------------------------------------------------+
|                        Presentation                           |
|                                                               |
|  AppCoordinator                                               |
|    |                                                          |
|    +-- UserListViewController <--> UserListViewModel          |
|    |                                 |                        |
|    |                          PaginationManager (observed)    |
|    |                                                          |
|    +-- UserDetailsViewController <--> UserDetailsViewModel    |
|                                         |                     |
|                               GetUserDetailsUseCase (Domain)  |
+-------------------------+---------------------+---------------+
                          |                     |
              (protocols) |                     | (protocols)
+-------------------------v---------------------v---------------+
|                          Domain                               |
|                                                               |
|  UserModel          UserDetailsModel         AppError         |
|  UserRepositoryProtocol                                       |
|  GetUserPagingUseCase   GetUserDetailsUseCase                 |
+-------------------------^-------------------------------------+
                          |
              (implements)|
+-------------------------+-------------------------------------+
|                           Data                                |
|                                                               |
|  UserRepositoryImpl  <-- UserServiceProtocol (UserService)    |
|  PaginationManager   <-- UserLocalDataSourceProtocol          |
|                      <-- PreferencesStoreProtocol             |
|                                                               |
|  APIClient (URLSession + SSLPinningDelegate)                  |
|  CoreDataManager (NSPersistentContainer)                      |
|  PreferencesStore (KeychainAccess)                            |
|  Mappers: UserResponseMapper, UserDetailsResponseMapper        |
+---------------------------------------------------------------+
```

Dependency inversion: Data and Presentation depend on Domain protocols, never on each other's concrete types.

---

## Dependency Flow

```
SceneDelegate
  --> UINavigationController
  --> AppCoordinator.start()
        --> UserListViewController(viewModel: UserListViewModel())
              UserListViewModel.init()  [convenience]
                --> Container.shared.paginationManager()  [singleton]
                      PaginationManager(userService:localDataSource:preferencesStore:)
                        userService      = Container.shared.userService()
                        localDataSource  = Container.shared.userLocalDataSource()
                        preferencesStore = Container.shared.preferencesStore()

              [on cell tap] --> AppCoordinator.showUserDetails(username:avatarUrl:url:)
                --> UserDetailsViewController(viewModel: UserDetailsViewModel(...))
                      UserDetailsViewModel
                        --> Container.shared.getUserDetailsUseCase()
                              GetUserDetailsUseCase(repository: userRepository)
                                --> UserRepositoryImpl(userService:localDataSource:preferencesStore:)
```

Factory resolves all singletons lazily on first access. `Container.shared` is the global DI root.

---

## Data Flow: User List Screen

### Initial Load

```
viewDidLoad
  --> viewModel.loadInitialData()
        --> performTask(showLoading: true)
              --> paginationManager.loadInitial()   [@MainActor]
                    1. loadCachedUsers()
                         --> localDataSource.fetchAll()  [Core Data viewContext]
                         --> UserResponseMapper.mapToDomainList(entities)
                         --> usersSubject.send(users)     [observed by ViewModel]
                    2. isCacheFresh()?
                         --> preferencesStore.getLastUpdatedUserList()  [Keychain]
                         --> elapsed <= 3600s?
                    3. if stale: await paginationManager.refresh()
                         --> userService.getUsers(perPage: 20, since: 0)  [async]
                               --> apiClient.request(.getUsers(...))
                                     --> URLSession.data(for: urlRequest)
                                     --> SSLPinningDelegate challenge
                                     --> JSONDecoder().decode([UserResponse].self)
                         --> localDataSource.upsertAndDeleteAll(needToDelete: true, ...)
                         --> preferencesStore.setLastUpdatedUserList(now)  [Keychain]
                         --> loadCachedUsers()  [re-read from Core Data]
                         --> usersSubject.send(users)

ViewModel.observePaginationManager()
  paginationManager.usersSubject  --> viewModel.users (Published)
  paginationManager.loadingSubject --> viewModel.paginationState (Published)

UserListViewController.setupBindings()
  viewModel.$users --> dataSource.apply(snapshot)   [UITableView update]
  viewModel.isLoadingPublisher --> loadingView.show/hide
  viewModel.errorPublisher --> ErrorAlertHelper.show
  viewModel.eventPublisher --> coordinatorDelegate.userListDidSelectUser
```

### Load Next Page

```
scrollViewDidScroll (near bottom)
  --> viewModel.loadNextPage()
        guard hasMorePages, paginationState != .loadingMore
        --> performTask { paginationManager.loadNextPage() }
              --> userService.getUsers(perPage: 20, since: lastUserId)
              --> localDataSource.upsertAndDeleteAll(needToDelete: false, ...)
              --> loadCachedUsers()
              --> usersSubject.send(accumulatedUsers)
```

### Pull-to-Refresh

```
UIRefreshControl valueChanged
  --> viewModel.refresh()
        --> paginationManager.refresh()   [clears cache, fetches page 1]
        --> isRefreshing state gating suppresses full-screen loading overlay
```

---

## Data Flow: User Details Screen

```
AppCoordinator.showUserDetails(username:avatarUrl:url:)
  --> UserDetailsViewModel(username:avatarUrl:url:)
        --> init calls performTask(showLoading: true)
              --> getUserDetailsUseCase(username: username)
                    --> repository.getUserDetails(username:)  [AnyPublisher]
                          --> Future { userService.getUserDetails(username:) }
                                --> apiClient.request(.getUserDetails(username:))
                                --> UserDetailsResponseMapper.mapToDomain(response)
                    --> .sink { model in setState(model) }

UserDetailsViewController.setupBindings()
  viewModel.statePublisher --> update all subviews
  viewModel.isLoadingPublisher --> loadingView
  viewModel.errorPublisher --> alert
```

---

## Combine Streams

| Subject | Type | Direction | Consumers |
|---------|------|-----------|-----------|
| `paginationManager.usersSubject` | `CurrentValueSubject<[UserModel], Never>` | Data → ViewModel | `UserListViewModel` |
| `paginationManager.loadingSubject` | `CurrentValueSubject<PaginationLoadState, Never>` | Data → ViewModel | `UserListViewModel` |
| `BaseViewModel.stateSubject` | `CurrentValueSubject<UiState, Never>` | ViewModel → VC | `UserListViewController`, `UserDetailsViewController` |
| `BaseViewModel.errorSubject` | `CurrentValueSubject<ErrorState, Never>` | ViewModel → VC | All VCs |
| `BaseViewModel.loadingSubject` | `CurrentValueSubject<Bool, Never>` | ViewModel → VC | All VCs |
| `BaseViewModel.eventSubject` | `PassthroughSubject<Event, Never>` | ViewModel → VC | Navigation events (no replay) |

All subjects and `@Published` properties on ViewModels are `@MainActor`. VCs subscribe on the main thread via `.receive(on: RunLoop.main)` or direct sink from `@MainActor` context.

---

## Coordinator Pattern

```
Coordinator (protocol)
  navigationController: UINavigationController
  childCoordinators: [Coordinator]
  start()

AppCoordinator: Coordinator
  start()               -> installs UserListViewController as root
  showUserDetails(...)  -> pushViewController
  handleDeepLink(url:)  -> parses gitpulse:// scheme, routes

UserListCoordinatorDelegate (protocol on AppCoordinator)
  userListDidSelectUser(username:avatarUrl:url:)
```

`UserListViewController` holds a `weak var coordinatorDelegate: UserListCoordinatorDelegate?`. On cell tap, the VC calls the delegate rather than pushing a VC directly. This keeps navigation logic out of VCs.

Deep link URL parsing:
- `gitpulse://users` → `popToRootViewController`
- `gitpulse://users/{username}` → `popToRootViewController` then `showUserDetails`

---

## Core Data Pagination Strategy

No `NSFetchedResultsController` for pagination (not using `NSFetchedResultsController`-driven diffing). Instead:

1. `UserLocalDataSource.fetchAll()` returns all `UserEntity` records sorted by `id` ascending
2. `PaginationManager` accumulates pages in Core Data (`upsertAndDeleteAll(needToDelete: false)` appends)
3. After each page write, `loadCachedUsers()` re-fetches the full sorted list from Core Data and publishes via `usersSubject`
4. The ViewModel's `users` array always reflects the complete accumulated list from Core Data

Cursor tracking: `lastUserId` is updated after each `loadCachedUsers()` call from `models.last?.id`.

Cache invalidation: on `refresh()`, `upsertAndDeleteAll(needToDelete: true)` wipes existing records before writing page 1.

---

## SSL Pinning Flow

```
URLSession.data(for: urlRequest)
  --> SSLPinningDelegate.urlSession(_:didReceive:completionHandler:)
        1. Check authenticationMethod == NSURLAuthenticationMethodServerTrust
        2. Extract host from protectionSpace
        3. Look up expectedHashes from pinnedDomains[host]
        4. if no entry -> performDefaultHandling (non-pinned domain)
        5. SecTrustEvaluateWithError(serverTrust)
        6. Extract leaf certificate: SecTrustCopyCertificateChain (iOS 15+)
                                  or SecTrustGetCertificateAtIndex (iOS < 15)
        7. SecCertificateCopyKey -> SecKeyCopyExternalRepresentation -> Data
        8. SHA256.hash(data: publicKeyData) -> base64EncodedString
        9. if expectedHashes.contains(hashBase64):
              completionHandler(.useCredential, URLCredential(trust:))
           else:
              DEBUG -> log, performDefaultHandling
              RELEASE -> cancelAuthenticationChallenge
```

Pin rotation procedure: generate new hash via `openssl s_client ... | openssl dgst -sha256 -binary | openssl enc -base64`, add as backup pin before removing old primary.

---

## Security Architecture

| Concern | Mechanism |
|---------|-----------|
| Transport | SSL pinning via `SSLPinningDelegate` (SHA256 public key hash) |
| Local data | Core Data `NSFileProtectionComplete` on persistent store |
| Preferences | Keychain via `KeychainAccess`, `.whenUnlockedThisDeviceOnly` |
| Release build | Mismatch cancels TLS handshake; no fallback |
| Debug build | Mismatch logged, default system validation used |

---

## Related Docs

- [Codebase Summary](./codebase-summary.md)
- [Code Standards](./code-standards.md)
- [Project Overview](./project-overview-pdr.md)
