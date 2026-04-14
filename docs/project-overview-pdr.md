# Project Overview & PDR — GitPulse iOS

## Vision

GitPulse is an iOS GitHub Users browser demonstrating Clean Architecture with UIKit, Combine, Core Data, and Factory DI. Strict layer separation, protocol-driven boundaries, and offline-first data.

---

## Goals

1. Demonstrate Clean Architecture applied to UIKit — strict layer separation (Domain / Data / Presentation), protocol-driven boundaries, dependency inversion.
2. Provide a reference codebase for Combine + Factory DI + Core Data paired with UIKit programmatic UI.
3. Implement offline-first data strategy with cache expiry and cursor-based pagination.
4. Meet production-quality security standards: SSL pinning, Core Data file protection, Keychain preferences.

---

## Target Users

- iOS developers learning Clean Architecture patterns
- Teams evaluating UIKit programmatic UI + Combine as a stack
- Engineers wanting a worked example of offline-first pagination on iOS

---

## Scope

### In Scope

| Area | Details |
|------|---------|
| User list | Paginated list (20 per page), offline-first, pull-to-refresh |
| User details | Avatar, name, login, followers, following, country, blog URL |
| Navigation | Coordinator pattern, UINavigationController push/pop |
| Deep links | `gitpulse://users`, `gitpulse://users/{username}` |
| Dark mode | Asset Catalog semantic colors, `BrandPrimary` with light/dark variants |
| Accessibility | Dynamic Type, minimum 44pt touch targets |
| Security | SSL pinning, Core Data `NSFileProtectionComplete`, Keychain preferences |
| Testing | Unit tests for Domain, Data, Presentation layers (20 tests) |

### Non-Goals

- Authentication / GitHub OAuth login
- Search functionality
- Favorites / bookmarks
- Push notifications
- SwiftUI implementation
- iPad split-view controller (layout adapts but no explicit UISplitViewController)
- App Store submission (no real SSL pin hashes in current build)

---

## Feature List

### User List Screen

- Displays GitHub users from `GET /users?per_page=20&since={lastId}`
- First load shows cached Core Data records, refreshes if cache older than 1 hour
- `UITableView` with diffable data source (`NSDiffableDataSourceSnapshot<Section, UserModel>`)
- `LoadMoreFooterView` triggers `loadNextPage()` when visible
- Pull-to-refresh calls `PaginationManager.refresh()`, clears cache, fetches page 1
- Error state: alert dialog for full-screen errors, inline footer for append errors
- Loading state: `UIActivityIndicatorView` overlay during initial load

### User Details Screen

- `GET /users/{username}` on each navigation
- Displays: avatar (96pt circle), display name, @login, followers count, following count, country (flag + text), blog URL (tappable, opens Safari)
- "View on GitHub" button opens `user.url` in `SFSafariViewController`
- `UIScrollView` with vertical stack layout

### Pagination Strategy

- `PaginationManager` tracks `lastUserId` (cursor), `hasMorePages`, `isLoading`
- States: `idle`, `refreshing`, `loadingMore`, `error(Error)`
- Page size: 20 (constant `PaginationManager.pageSize`)
- Cache timeout: 3600 seconds (1 hour, constant `PaginationManager.cacheTimeout`)

### Security

- SSL pinning: `SSLPinningDelegate` (custom `URLSessionDelegate`) validates leaf certificate public key SHA256 hash against pinned values
  - Debug builds log mismatch and fall back to default handling
  - Release builds cancel the connection on mismatch
- Core Data: `NSFileProtectionComplete` on the persistent store
- Preferences (cache timestamp): stored in Keychain with `.whenUnlockedThisDeviceOnly` accessibility

---

## Success Metrics

| Metric | Target |
|--------|--------|
| All 12 phases complete | Done |
| Unit test pass rate | 100% (20/20) |
| Layer boundary violations | 0 (Domain imports no UIKit/Data) |
| File size | <200 LOC per Swift file |
| Dark mode rendering | Correct on all screens |
| Deep link routing | Both URL patterns verified |

---

## Technical Constraints

- Xcode 15+ required (PBXFileSystemSynchronizedRootGroup for auto file sync)
- iOS 15.0 minimum deployment target
- No storyboards except `LaunchScreen.storyboard`
- SSL pin hashes in `SSLPinningDelegate.defaultPins` are placeholders — must be replaced with real hashes before App Store submission
- `KeychainAccess` and `Factory` resolved via Swift Package Manager

---

## Dependencies

| Package | Purpose | Resolution |
|---------|---------|------------|
| Factory | Dependency injection container | SPM |
| Kingfisher | Async image loading + caching | SPM |
| SnapKit | AutoLayout DSL | SPM |
| KeychainAccess | Keychain wrapper | SPM |

---

## Related Docs

- [System Architecture](./system-architecture.md)
- [Code Standards](./code-standards.md)
- [Design Guidelines](./design-guidelines.md)
- [Project Roadmap](./project-roadmap.md)
