# GitPulse

A GitHub Users browser app for iOS, built with Clean Architecture, UIKit (programmatic), Combine, Factory DI, and Core Data.

---

## Stack

| Concern | Technology |
|---------|-----------|
| UI | UIKit (programmatic, SnapKit) |
| Reactive | Combine (`CurrentValueSubject`, `AnyPublisher`) |
| Async networking | `async`/`await` + `URLSession` |
| Dependency injection | Factory |
| Local persistence | Core Data |
| Image loading | Kingfisher |
| Secure preferences | KeychainAccess |
| Minimum iOS | 15.0 |
| Xcode | 15+ (PBXFileSystemSynchronizedRootGroup) |

---

## Requirements

- Xcode 15 or later
- iPhone 17 simulator (used for testing; any iOS 15+ device or simulator works)
- No additional build scripts required — SPM resolves dependencies on first open

---

## Setup & Run

```bash
# Clone
git clone https://github.com/<your-handle>/GitPulse-CleanArchitecture.git
cd GitPulse-CleanArchitecture

# Open in Xcode (SPM fetches dependencies automatically)
open GitPulse/GitPulse.xcodeproj
```

Select the **GitPulse** scheme and an iPhone simulator, then press Run (Cmd+R).

### Run Tests

```bash
xcodebuild test \
  -project GitPulse/GitPulse.xcodeproj \
  -scheme GitPulse \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

20 unit tests across Domain, Data, and Presentation layers. See `GitPulse/GitPulseTests/`.

---

## Architecture Overview

Three layers with strict inward-only dependencies:

```
+--------------------------------------------+
|             Presentation                   |
|  UserListViewController  UserListViewModel  |
|  UserDetailsViewController                 |
|  Coordinators  Theme  Base                 |
+--------------------+-----------------------+
                     | depends on (protocols)
+--------------------v-----------------------+
|               Domain                       |
|  UserModel  UserDetailsModel  AppError     |
|  UserRepositoryProtocol                    |
|  GetUserPagingUseCase                      |
|  GetUserDetailsUseCase                     |
+--------------------+-----------------------+
                     | implemented by
+--------------------v-----------------------+
|                 Data                       |
|  APIClient  UserService  SSLPinningDelegate|
|  CoreDataManager  UserLocalDataSource      |
|  PreferencesStore  PaginationManager       |
|  UserRepositoryImpl  Mappers               |
+--------------------------------------------+
```

Domain has no imports from Data or Presentation. Data imports only Domain protocols. Presentation imports Domain models and protocols; Factory DI wires the concrete implementations at startup.

---

## Folder Structure

```
GitPulse/GitPulse/
├── Domain/
│   ├── Models/          UserModel, UserDetailsModel
│   ├── Errors/          AppError
│   ├── Repositories/    UserRepositoryProtocol
│   └── UseCases/        GetUserPagingUseCase, GetUserDetailsUseCase
├── Data/
│   ├── Network/         APIClient, APIEndpoint, SSLPinningDelegate
│   │   ├── Responses/   UserResponse, UserDetailsResponse, ErrorResponse
│   │   └── Services/    UserService
│   ├── Persistence/     CoreDataManager, UserLocalDataSource, PreferencesStore
│   │   └── Entities/    UserEntity (Core Data)
│   ├── Repositories/    UserRepositoryImpl, PaginationManager
│   │   └── Mappers/     UserResponseMapper, UserDetailsResponseMapper
│   └── DI/              DataContainer (Factory registrations)
├── Presentation/
│   ├── Base/            BaseViewModel, LoadingView, ErrorState, ErrorAlertHelper
│   ├── Coordinators/    Coordinator protocol, AppCoordinator
│   ├── UserList/        UserListViewController, UserListViewModel
│   │   └── Components/  UserCell, LoadMoreFooterView
│   ├── UserDetails/     UserDetailsViewController, UserDetailsViewModel
│   │   └── Components/  UserDetailsCardView, UserDetailsStatsView, UserBlogView, UserCountryView
│   └── Theme/           AppColors, AppTypography
├── DI/                  AppContainer (empty — DataContainer extends Container)
├── Extensions/          BundleExtensions
├── AppDelegate.swift
└── SceneDelegate.swift
```

---

## Key Features

- Offline-first user list: loads cached users from Core Data, refreshes from GitHub API when cache exceeds 1 hour
- Cursor-based pagination via `PaginationManager`
- Pull-to-refresh with refresh-state gating in `UserListViewModel`
- User details: avatar, name, followers, following, country, blog URL
- Deep links: `gitpulse://users` and `gitpulse://users/{username}`
- Dark mode via Asset Catalog `BrandPrimary` color set with light/dark variants
- SSL certificate pinning (`SSLPinningDelegate` on URLSession)
- Core Data encryption via `NSFileProtectionComplete`
- Preferences stored in Keychain (`KeychainAccess`, `.whenUnlockedThisDeviceOnly`)
- Dynamic Type accessibility via `UIFont.preferredFont(forTextStyle:)`
- Adaptive layout: single-column iPhone, readable content guide on iPad

---

## Deep Links

| URL | Behavior |
|-----|----------|
| `gitpulse://users` | Pop to user list root |
| `gitpulse://users/{username}` | Open user details for `{username}` |

---

## Documentation

| File | Description |
|------|-------------|
| [docs/project-overview-pdr.md](docs/project-overview-pdr.md) | Vision, goals, features, non-goals |
| [docs/system-architecture.md](docs/system-architecture.md) | Layer diagrams, data flow, Combine streams |
| [docs/code-standards.md](docs/code-standards.md) | Swift style, naming, layering rules, DI conventions |
| [docs/codebase-summary.md](docs/codebase-summary.md) | File tour, LOC breakdown, module map |
| [docs/design-guidelines.md](docs/design-guidelines.md) | Colors, typography, spacing, components |
| [docs/project-roadmap.md](docs/project-roadmap.md) | Phase tracker, deferred items, future work |

---

## License

MIT
