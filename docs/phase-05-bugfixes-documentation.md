# Phase 05 Bug Fixes Documentation

## Overview

This document details the bugs found and fixed in Phase 05 (Data Layer: Repository Implementation) during code review on 2026-04-11.

---

## Issue 1: Type Mismatch - Int32 vs Int

### Severity: Critical (Build Blocker)

### Description

The `UserResponseMapper` was returning `Int32` for the `id` field in tuples, but `UserLocalDataSourceProtocol` expected `Int`. This caused 3 compile errors:

```
PaginationManager.swift:107:79: error: cannot convert value of type 
  '[(id: Int32, username: String, avatarUrl: String, url: String)]' to expected argument type 
  '[(id: Int, username: String, avatarUrl: String, url: String)]'

PaginationManager.swift:137:80: error: (same as above)

UserRepositoryImpl.swift:106:57: error: (same as above)
```

### Root Cause

The original plan (phase-05-data-layer-repository.md) specified `Int32` in the mapper:

```swift
// Original (incorrect)
static func mapToLocal(_ response: UserResponse) -> (id: Int32, ...) {
    return (id: Int32(response.id ?? 0), ...)
}
```

But `UserLocalDataSourceProtocol` (created in Phase 04) defined the tuple with `Int`:

```swift
func upsertAndDeleteAll(
    needToDelete: Bool,
    users: [(id: Int, username: String, avatarUrl: String, url: String)]
) throws
```

### Why Int32 Was Used

The spec likely used `Int32` because:
1. Android's `id: Int` is 32-bit
2. Core Data stores integers as `Int64` internally

However, Swift's `Int` is the idiomatic choice for cross-layer data structures because:
1. `Int` is platform-native (64-bit on modern iOS devices)
2. Avoids unnecessary type conversions
3. The actual Core Data `Int64` conversion happens in `UserLocalDataSource.performUpsert()`

### Fix Applied

Changed mapper to use `Int` consistently:

```swift
// Fixed
static func mapToLocal(_ response: UserResponse) -> (id: Int, ...) {
    return (id: response.id ?? 0, ...)  // Int, not Int32
}
```

### Files Modified

- `Data/Repositories/Mappers/UserResponseMapper.swift`
- `Data/Repositories/UserRepositoryImpl.swift` (in `saveUsers()`)

---

## Issue 2: Missing DI Registration for PaginationManager

### Severity: Important

### Description

The phase 05 spec required a `paginationManager` factory in `DataContainer.swift`, but it was missing. While the app could compile without it, the `PaginationManager` would not be properly dependency-injected, breaking the singleton pattern.

### Why It Matters

Without a singleton factory:
1. Each call to `UserRepositoryImpl.paginationManager` creates a new lazy instance
2. If multiple ViewModels access the repository, they get different pagination states
3. Cache freshness checks become inconsistent

### Fix Applied

Added the missing factory:

```swift
// Data/DI/DataContainer.swift
var paginationManager: Factory<PaginationManager> {
    self {
        PaginationManager(
            userService: self.userService(),
            localDataSource: self.userLocalDataSource(),
            preferencesStore: self.preferencesStore()
        )
    }.singleton
}
```

---

## Issue 3: Future Never Completes When Self Is Nil

### Severity: Important

### Description

In `UserRepositoryImpl`, several methods used `Future` with `[weak self]` capture, but if `self` became `nil`, the promise was never called:

```swift
// Original (bug)
Future<[UserModel], Error> { [weak self] promise in
    Task {
        do {
            guard let self else { return }  // <-- Promise never called
            ...
        }
    }
}
```

### Why It's a Problem

When a `Future` promise is never fulfilled:
1. Subscribers wait indefinitely
2. Combine pipelines hang
3. UI may freeze waiting for data
4. Memory leaks if subscribers hold strong references

### When Does Self Become Nil?

The repository is registered as `.singleton` in Factory, so `self` becoming `nil` is unlikely during normal operation. However:
1. During app termination
2. In unit tests with manual deallocation
3. If DI container is reset/recreated

### Fix Applied

Return an error instead of silently returning:

```swift
// Fixed
Future<[UserModel], Error> { [weak self] promise in
    Task {
        do {
            guard let self else {
                promise(.failure(AppError.unknown("Repository deallocated")))
                return
            }
            ...
        }
    }
}
```

### Files Modified

- `Data/Repositories/UserRepositoryImpl.swift`
  - `getUsers(perPage:since:)`
  - `getUserDetails(username:)`
  - `getCachedUsers()`
  - `saveUsers(_:clearExisting:)`

---

## Verification

After applying all fixes:

```bash
xcodebuild -scheme GitPulse -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build

** BUILD SUCCEEDED **
```

---

## Lessons Learned

### 1. Type Consistency Across Layers

When defining data transfer structures (DTOs, tuples), ensure type consistency across all layers:
- Domain models (Swift `Int`)
- Data layer mappers (Swift `Int`)
- Persistence layer (Core Data `Int64`)

The conversion should happen at the boundary closest to the external system (Core Data), not in the mapper.

### 2. Spec Validation Before Implementation

The original spec contained the `Int32` vs `Int` mismatch. Future specs should be validated against existing protocol signatures before implementation.

### 3. Future/Promise Completion Guarantee

Always ensure `Future` promises are fulfilled on all code paths:

```swift
// Pattern: Handle all exit paths
Future<T, Error> { [weak self] promise in
    guard let self else {
        promise(.failure(SomeError.deallocated))
        return
    }
    do {
        let result = try someWork()
        promise(.success(result))
    } catch {
        promise(.failure(error))
    }
}
```

---

## Related Files

| File | Purpose |
|------|---------|
| `Data/Repositories/Mappers/UserResponseMapper.swift` | DTO to tuple/domain mapping |
| `Data/Repositories/Mappers/UserDetailsResponseMapper.swift` | User details mapping |
| `Data/Repositories/PaginationManager.swift` | Offline-first pagination state |
| `Data/Repositories/UserRepositoryImpl.swift` | Repository implementation |
| `Data/DI/DataContainer.swift` | Dependency injection |
| `Data/Persistence/UserLocalDataSource.swift` | Core Data operations |
