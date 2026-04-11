//
//  PreferencesStore.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation
import KeychainAccess

/// Secure key-value store — equivalent to Android's EncryptedDataStore.
///
/// Android mapping:
/// - DataStore<Preferences> -> KeychainAccess.Keychain
/// - longPreferencesKey("last_updated_user_list") -> String key in Keychain
/// - dataStore.edit { prefs -> prefs[KEY] = value } -> keychain.set(value, key:)
/// - dataStore.data.map { prefs -> prefs[KEY] } -> keychain.get(key)
///
/// WHY Keychain instead of UserDefaults?
/// Android uses EncryptedDataStore (encrypted at rest). The iOS equivalent is Keychain,
/// which is hardware-encrypted and persists across app reinstalls. UserDefaults is like
/// SharedPreferences (unencrypted, deleted on uninstall).
protocol PreferencesStoreProtocol {
    func setLastUpdatedUserList(_ timestamp: TimeInterval)
    func getLastUpdatedUserList() -> TimeInterval
}

final class PreferencesStore: PreferencesStoreProtocol {

    private let keychain: Keychain

    private enum Keys {
        /// Equivalent to: longPreferencesKey("last_updated_user_list")
        static let lastUpdatedUserList = "last_updated_user_list"
    }

    init(service: String = "com.gitpulse.preferences") {
        self.keychain = Keychain(service: service)
    }

    /// Store timestamp — equivalent to: dataStore.edit { prefs -> prefs[KEY] = value }
    func setLastUpdatedUserList(_ timestamp: TimeInterval) {
        do {
            try keychain.set(String(timestamp), key: Keys.lastUpdatedUserList)
        } catch {
            print("[Keychain] Failed to set lastUpdatedUserList: \(error.localizedDescription)")
        }
    }

    /// Read timestamp — equivalent to: dataStore.data.map { prefs -> prefs[KEY].orZero() }
    /// Returns 0 if not set (same as Android's .orZero())
    func getLastUpdatedUserList() -> TimeInterval {
        guard let value = keychain[Keys.lastUpdatedUserList],
              let timestamp = TimeInterval(value) else {
            return 0
        }
        return timestamp
    }
}
