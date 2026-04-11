//
//  UserEntity+CoreDataProperties.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

extension UserEntity {

    /// Equivalent to Room's @Query — creates a fetch request for this entity type.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    /// @NSManaged = Core Data manages storage. Equivalent to @ColumnInfo in Room.
    @NSManaged public var id: Int64
    @NSManaged public var username: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var url: String?
}

extension UserEntity: Identifiable {}
