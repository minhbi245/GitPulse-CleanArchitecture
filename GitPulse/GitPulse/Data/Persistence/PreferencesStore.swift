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
}

final class PreferencesStore: PreferencesStoreProtocol {

    private let keychain: Keychain

    private enum Keys {
        static let lastUpdatedUserList = "last_updated_user_list"
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
}
