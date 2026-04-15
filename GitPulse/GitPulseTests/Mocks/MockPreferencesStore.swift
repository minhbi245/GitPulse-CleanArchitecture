//
//  MockPreferencesStore.swift
//  GitPulseTests
//

import Foundation
@testable import GitPulse

final class MockPreferencesStore: PreferencesStoreProtocol {

    var lastUpdatedTimestamp: TimeInterval = 0
    var lastUserListCursor: Int = 0
    var hasMoreUsers: Bool = true

    func setLastUpdatedUserList(_ timestamp: TimeInterval) {
        lastUpdatedTimestamp = timestamp
    }

    func getLastUpdatedUserList() -> TimeInterval {
        lastUpdatedTimestamp
    }

    func setLastUserListCursor(_ userId: Int) {
        lastUserListCursor = userId
    }

    func getLastUserListCursor() -> Int {
        lastUserListCursor
    }

    func setHasMoreUsers(_ hasMore: Bool) {
        hasMoreUsers = hasMore
    }

    func getHasMoreUsers() -> Bool {
        hasMoreUsers
    }
}
