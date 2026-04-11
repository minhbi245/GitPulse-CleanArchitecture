//
//  UserEntity+CoreDataClass.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import CoreData

/// Core Data managed object — equivalent to Room's @Entity UserEntity.
///
/// WHY @objc and @NSManaged?
/// Core Data was built in Objective-C era. @NSManaged tells Swift that Core Data
/// manages these properties at runtime (like Room generates getters/setters).
/// @objc(UserEntity) ensures the Objective-C runtime can find this class.
@objc(UserEntity)
public class UserEntity: NSManagedObject {}
