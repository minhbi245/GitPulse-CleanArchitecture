//
//  CoreDataManager.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

/// Manages the Core Data stack — equivalent to Room's UserDatabase.
///
/// Android mapping:
/// - Room.databaseBuilder() -> NSPersistentContainer()
/// - UserDatabase.Factory.create() -> CoreDataManager.init()
/// - SQLCipher encryption -> NSFileProtectionComplete (Phase 10)
///
/// WHY singleton?
/// Same as Android — Room database is provided as @Singleton by Hilt.
/// One database instance, one persistent container, shared across the app.
final class CoreDataManager {

    static let shared = CoreDataManager()

    /// Equivalent to Room's RoomDatabase instance.
    let persistentContainer: NSPersistentContainer

    /// Main thread context for reads — equivalent to Room's main thread queries.
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        // Equivalent to Room.databaseBuilder(context, UserDatabase::class.java, "github_users.db")
        persistentContainer = NSPersistentContainer(name: "GitPulse")

        // Configure file protection (equivalent to SQLCipher at a different level).
        if let storeDescription = persistentContainer.persistentStoreDescriptions.first {
            storeDescription.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("[CoreData] Failed to load persistent store: \(error.localizedDescription)")
            }
        }

        // Auto-merge changes from background contexts — like Room's auto-invalidation.
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Create a background context for write operations.
    /// Equivalent to Room's @Transaction running on a background thread.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Save context if there are changes.
    /// Called from SceneDelegate.sceneDidEnterBackground().
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("[CoreData] Save error: \(error.localizedDescription)")
            }
        }
    }
}
