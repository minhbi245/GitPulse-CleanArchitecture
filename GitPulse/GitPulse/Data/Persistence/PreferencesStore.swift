//
//  PreferencesStore.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation

/// App-state key-value store backed by `UserDefaults`.
///
/// This store holds **non-sensitive cache metadata** (timestamps, pagination
/// cursor, end-of-list flag). UserDefaults is the right tool because:
///
/// - Data is **wiped automatically when the app is uninstalled**, which keeps
///   cache metadata in lockstep with the CoreData cache (also wiped).
/// - Fast (in-memory with lazy disk flush) — no I/O overhead per read.
/// - No encryption cost for data that isn't secret.
///
/// Previously this store was backed by Keychain, which survives app uninstall
/// — that caused a "fresh install → blank screen" bug where stale Keychain
/// `lastUpdated` timestamps made the offline-first layer think the empty
/// CoreData cache was still fresh, so no network fetch was triggered.
///
/// **For future auth tokens**, introduce a separate `SecureStore` (Keychain)
/// rather than mixing secrets back into this store.
protocol PreferencesStoreProtocol {
    func setLastUpdatedUserList(_ timestamp: TimeInterval)
    func getLastUpdatedUserList() -> TimeInterval

    /// Last fetched user id — pagination cursor for GitHub `since` query.
    func setLastUserListCursor(_ userId: Int)
    func getLastUserListCursor() -> Int

    /// Whether more pages are available — persisted so cold launches resume correctly.
    func setHasMoreUsers(_ hasMore: Bool)
    func getHasMoreUsers() -> Bool
}

final class PreferencesStore: PreferencesStoreProtocol {

    private let defaults: UserDefaults

    private enum Keys {
        static let lastUpdatedUserList = "last_updated_user_list"
        static let lastUserListCursor = "last_user_list_cursor"
        static let hasMoreUsers = "has_more_users"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func setLastUpdatedUserList(_ timestamp: TimeInterval) {
        defaults.set(timestamp, forKey: Keys.lastUpdatedUserList)
    }

    /// Returns 0 if not yet set — `UserDefaults.double(forKey:)` returns 0 for missing keys.
    func getLastUpdatedUserList() -> TimeInterval {
        defaults.double(forKey: Keys.lastUpdatedUserList)
    }

    func setLastUserListCursor(_ userId: Int) {
        defaults.set(userId, forKey: Keys.lastUserListCursor)
    }

    /// Returns 0 if not yet set — caller treats 0 as "start from the beginning".
    func getLastUserListCursor() -> Int {
        defaults.integer(forKey: Keys.lastUserListCursor)
    }

    func setHasMoreUsers(_ hasMore: Bool) {
        defaults.set(hasMore, forKey: Keys.hasMoreUsers)
    }

    /// Defaults to `true` so a fresh install attempts pagination.
    ///
    /// `UserDefaults.bool(forKey:)` returns `false` for missing keys, but we
    /// want `true` as the fresh-install default — hence the explicit nil check.
    func getHasMoreUsers() -> Bool {
        guard defaults.object(forKey: Keys.hasMoreUsers) != nil else { return true }
        return defaults.bool(forKey: Keys.hasMoreUsers)
    }
}
