//
//  CoreDataManager.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

/// Manages the Core Data stack — single persistent container shared across the app.
///
/// One database instance, one persistent container, shared as a singleton so all
/// layers access the same underlying store.
final class CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    /// Main thread context for reads.
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "GitPulse")

        // File protection encrypts the store at rest when the device is locked.
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

        // Auto-merge changes from background contexts into the view context.
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Create a background context for write operations.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Save the view context if there are pending changes.
    /// Called from `SceneDelegate.sceneDidEnterBackground()`.
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
