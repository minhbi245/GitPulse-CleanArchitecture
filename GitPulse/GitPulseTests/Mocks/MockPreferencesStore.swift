//
//  MockPreferencesStore.swift
//  GitPulseTests
//

import Foundation
@testable import GitPulse

final class MockPreferencesStore: PreferencesStoreProtocol {

    var lastUpdatedTimestamp: TimeInterval = 0

    func setLastUpdatedUserList(_ timestamp: TimeInterval) {
        lastUpdatedTimestamp = timestamp
    }

    func getLastUpdatedUserList() -> TimeInterval {
        lastUpdatedTimestamp
    }
}
