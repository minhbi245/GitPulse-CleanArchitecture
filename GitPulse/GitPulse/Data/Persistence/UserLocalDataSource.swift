//
//  UserLocalDataSource.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

/// Local data source for cached users — equivalent to Room's UserDao.
///
/// Android mapping:
/// - @Dao interface -> UserLocalDataSourceProtocol
/// - @Query("SELECT * FROM UserEntity") -> NSFetchRequest
/// - @Upsert -> manual fetch-or-insert in a background context
/// - @Transaction -> performAndWait {} block
/// - PagingSource -> fetchAll() returns array (pagination at repository level)
///
/// WHY protocol + implementation?
/// Same pattern as Android: UserDao is an interface, Room generates the impl.
/// We define protocol for testability, write impl manually.
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
    /// Equivalent to: @Query("SELECT * FROM UserEntity")
    /// Uses viewContext.performAndWait to ensure thread-safe access.
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

    /// Insert or update users.
    /// Equivalent to: @Upsert suspend fun upsertAll(entities)
    ///
    /// Room's @Upsert does: INSERT OR REPLACE. Core Data has no built-in upsert,
    /// so we batch-fetch existing by ID set, then update or create new.
    func upsertAll(
        _ users: [(id: Int, username: String, avatarUrl: String, url: String)]
    ) throws {
        let context = coreDataManager.newBackgroundContext()
        try context.performAndWait {
            try performUpsert(users, in: context)
            try context.save()
        }
    }

    /// Delete all cached users.
    /// Equivalent to: @Query("DELETE FROM UserEntity")
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

    /// Atomic delete + insert in a single context — equivalent to @Transaction upsertAndDeleteAll().
    /// Uses context-level delete (not batch) so both operations share one save.
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
