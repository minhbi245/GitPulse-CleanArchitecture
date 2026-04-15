//
//  PreferencesStore.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation
import KeychainAccess

/// Secure key-value store backed by Keychain.
///
/// Keychain is hardware-encrypted and persists across app reinstalls,
/// making it the appropriate choice for sensitive timestamps and tokens.
/// `.whenUnlockedThisDeviceOnly` ensures data is accessible only when the
/// device is unlocked and is never migrated to new devices.
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

    private let keychain: Keychain

    private enum Keys {
        static let lastUpdatedUserList = "last_updated_user_list"
        static let lastUserListCursor = "last_user_list_cursor"
        static let hasMoreUsers = "has_more_users"
    }

    init(service: String = "com.gitpulse.preferences") {
        self.keychain = Keychain(service: service)
            .accessibility(.whenUnlockedThisDeviceOnly)
    }

    func setLastUpdatedUserList(_ timestamp: TimeInterval) {
        do {
            try keychain.set(String(timestamp), key: Keys.lastUpdatedUserList)
        } catch {
            print("[Keychain] Failed to set lastUpdatedUserList: \(error.localizedDescription)")
        }
    }

    /// Returns 0 if not yet set.
    func getLastUpdatedUserList() -> TimeInterval {
        guard let value = keychain[Keys.lastUpdatedUserList],
              let timestamp = TimeInterval(value) else {
            return 0
        }
        return timestamp
    }

    func setLastUserListCursor(_ userId: Int) {
        do {
            try keychain.set(String(userId), key: Keys.lastUserListCursor)
        } catch {
            print("[Keychain] Failed to set lastUserListCursor: \(error.localizedDescription)")
        }
    }

    /// Returns 0 if not yet set — caller treats 0 as "start from the beginning".
    func getLastUserListCursor() -> Int {
        guard let value = keychain[Keys.lastUserListCursor],
              let cursor = Int(value) else {
            return 0
        }
        return cursor
    }

    func setHasMoreUsers(_ hasMore: Bool) {
        do {
            try keychain.set(hasMore ? "1" : "0", key: Keys.hasMoreUsers)
        } catch {
            print("[Keychain] Failed to set hasMoreUsers: \(error.localizedDescription)")
        }
    }

    /// Defaults to `true` so a fresh install attempts pagination.
    func getHasMoreUsers() -> Bool {
        guard let value = keychain[Keys.hasMoreUsers] else { return true }
        return value == "1"
    }
}
