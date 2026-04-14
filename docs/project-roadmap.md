# Project Roadmap — GitPulse iOS

## Phase Tracker

All 12 phases complete as of 2026-04-14.

| # | Phase | Status | Est. Effort | Key Deliverables |
|---|-------|--------|-------------|-----------------|
| 01 | Project Setup | Done | 3h | Xcode project, SPM packages, folder structure, SceneDelegate |
| 02 | Domain Layer | Done | 2h | `UserModel`, `UserDetailsModel`, `AppError`, `UserRepositoryProtocol`, use cases |
| 03 | Data: Networking | Done | 4h | `APIClient`, `APIEndpoint`, `UserService`, DTOs, `NetworkErrorMapper` |
| 04 | Data: Persistence | Done | 3h | `CoreDataManager`, `UserEntity`, `UserLocalDataSource`, `PreferencesStore` |
| 05 | Data: Repository | Done | 4h | `UserRepositoryImpl`, `PaginationManager`, mappers, `DataContainer` |
| 06 | Presentation: Base | Done | 3h | `BaseViewModel`, `ErrorState`, `LoadingView`, `ErrorAlertHelper`, `ViewModelBindingHelper` |
| 07 | User List Screen | Done | 5h | `UserListViewController`, `UserListViewModel`, `UserCell`, `LoadMoreFooterView` |
| 08 | User Details Screen | Done | 4h | `UserDetailsViewController`, `UserDetailsViewModel`, detail sub-components |
| 09 | Navigation + Deep Links | Done | 3h | `Coordinator`, `AppCoordinator`, `gitpulse://` URL routing, `SceneDelegate` wiring |
| 10 | Security Layer | Done | 2h | `SSLPinningDelegate`, Core Data `NSFileProtectionComplete`, Keychain preferences |
| 11 | Unit Tests | Done | 4h | 20 tests — Domain (5), Data (9), Presentation (6), Mocks (4 files) |
| 12 | Theming + Polish | Done | 3h | `AppColors`, `AppTypography`, `BrandPrimary/Secondary/Tertiary` asset catalog sets |

Total delivered: ~40h, ~3,300 LOC, 46 Swift source files, 9 test files.

---

## Deferred Items

These items were descoped from the 12-phase plan and are not implemented:

| Item | Reason Deferred | Priority |
|------|----------------|----------|
| Real SSL pin hashes for `api.github.com` | Placeholder hashes used; requires live certificate inspection before App Store submission | High before release |
| App icon asset (`AppIcon.appiconset`) | Asset catalog slot exists but icon artwork not created | Medium |
| Instruments / performance profiling | No performance regressions observed; profiling deferred to post-MVP | Low |
| Integration / UI automation tests | `GitPulseUITests` target exists but contains only Xcode-generated stubs | Medium |
| iPad `UISplitViewController` | Layout adapts via readable content guide but no explicit split view | Low |

---

## Future Enhancements

Potential additions beyond current scope:

| Feature | Notes |
|---------|-------|
| User search | `GET /search/users?q={query}` — new use case, new screen or search controller on list |
| Favorites / bookmarks | Local Core Data entity; no API required |
| GitHub OAuth login | Personal access token or OAuth flow; required for authenticated rate limits (60 → 5000 req/hr) |
| Repository list per user | `GET /users/{username}/repos` — new screen, extend domain model |
| Widget extension | Surface recently viewed users via WidgetKit |
| SwiftUI migration | Incremental — replace UIKit screens with SwiftUI views, keeping same ViewModels |
| Localization | English only currently; `Localizable.strings` scaffolding needed |
| Snapshot tests | Add `swift-snapshot-testing` for UI regression coverage |
| iPad `UISplitViewController` | Side-by-side master/detail on larger screens |

---

## Current Capability Summary

| Capability | Status |
|-----------|--------|
| User list with offline-first pagination | Done |
| User details (avatar, name, stats, country, blog) | Done |
| Pull-to-refresh | Done |
| Dark mode | Done |
| Deep links | Done |
| SSL pinning | Done (placeholder hashes) |
| Encrypted local storage | Done (NSFileProtectionComplete + Keychain) |
| Dynamic Type accessibility | Done |
| Adaptive layout (tablet) | Partial (readable content guide, no split view) |
| Unit tests | Done (20 tests) |
| Search | Not implemented |
| Favorites | Not implemented |

---

## Related Docs

- [Project Overview & PDR](./project-overview-pdr.md)
- [System Architecture](./system-architecture.md)
- [Codebase Summary](./codebase-summary.md)
