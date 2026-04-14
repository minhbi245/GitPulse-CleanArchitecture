//
//  UserLocalDataSource.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

/// Local data source for cached users backed by Core Data.
///
/// The protocol enables testability — the implementation can be swapped for a mock.
/// Core Data has no built-in upsert, so `upsertAll` batch-fetches existing records
/// by ID, then updates or inserts as needed.
protocol UserLocalDataSourceProtocol {
    func fetchAll() throws -> [UserEntity]
    func upsertAll(_ users: [(id: Int, username: String, avatarUrl: String, url: String)]) throws
    func deleteAll() throws
    func upsertAndDeleteAll(
        needToDelete: Bool,
        users: [(id: Int, username: String, avatarUrl: String, url: String)]
    ) throws
}

final class UserLocalDataSource: UserLocalDataSourceProtocol {

    private let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }

    /// Fetch all cached users, ordered by ID.
    /// Uses `viewContext.performAndWait` to ensure thread-safe access.
    func fetchAll() throws -> [UserEntity] {
        var result: [UserEntity] = []
        var fetchError: Error?
        coreDataManager.viewContext.performAndWait {
            let request = UserEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            do {
                result = try self.coreDataManager.viewContext.fetch(request)
            } catch {
                fetchError = error
            }
        }
        if let error = fetchError { throw error }
        return result
    }

    /// Insert or update users in a background context.
    func upsertAll(
        _ users: [(id: Int, username: String, avatarUrl: String, url: String)]
    ) throws {
        let context = coreDataManager.newBackgroundContext()
        try context.performAndWait {
            try performUpsert(users, in: context)
            try context.save()
        }
    }

    /// Delete all cached users using a batch delete for efficiency.
    func deleteAll() throws {
        let context = coreDataManager.newBackgroundContext()
        try context.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs

            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDs = result?.result as? [NSManagedObjectID] ?? []

            // Merge deletion into view context so UI updates.
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [self.coreDataManager.viewContext]
            )
        }
    }

    /// Atomic delete + insert in a single context save.
    func upsertAndDeleteAll(
        needToDelete: Bool,
        users: [(id: Int, username: String, avatarUrl: String, url: String)]
    ) throws {
        let context = coreDataManager.newBackgroundContext()
        try context.performAndWait {
            if needToDelete {
                let request = UserEntity.fetchRequest()
                let existing = try context.fetch(request)
                existing.forEach { context.delete($0) }
            }
            try performUpsert(users, in: context)
            try context.save()
        }
    }

    // MARK: - Private

    /// Batch-fetch existing entities by ID, then update or insert.
    private func performUpsert(
        _ users: [(id: Int, username: String, avatarUrl: String, url: String)],
        in context: NSManagedObjectContext
    ) throws {
        let ids = users.map { NSNumber(value: $0.id) }
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let existing = try context.fetch(request)
        let lookup = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for user in users {
            let entity = lookup[Int64(user.id)] ?? UserEntity(context: context)
            entity.id = Int64(user.id)
            entity.username = user.username
            entity.avatarUrl = user.avatarUrl
            entity.url = user.url
        }
    }
}
