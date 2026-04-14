//
//  MockUserLocalDataSource.swift
//  GitPulseTests
//

import Foundation
@testable import GitPulse

final class MockUserLocalDataSource: UserLocalDataSourceProtocol {

    typealias UserTuple = (id: Int, username: String, avatarUrl: String, url: String)

    var storedUsers: [UserTuple] = []
    var fetchAllEntities: [UserEntity] = []
    var shouldThrow = false
    var deleteCallCount = 0
    var upsertCallCount = 0

    func fetchAll() throws -> [UserEntity] {
        if shouldThrow { throw AppError.unknown("Mock fetch error") }
        return fetchAllEntities
    }

    func upsertAll(_ users: [UserTuple]) throws {
        if shouldThrow { throw AppError.unknown("Mock upsert error") }
        upsertCallCount += 1
        storedUsers.append(contentsOf: users)
    }

    func deleteAll() throws {
        if shouldThrow { throw AppError.unknown("Mock delete error") }
        deleteCallCount += 1
        storedUsers.removeAll()
    }

    func upsertAndDeleteAll(needToDelete: Bool, users: [UserTuple]) throws {
        if needToDelete { try deleteAll() }
        try upsertAll(users)
    }
}
