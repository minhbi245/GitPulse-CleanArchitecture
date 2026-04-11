//
//  UserResponseMapper.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation

/// Maps network DTOs to persistence/domain types.
/// Maps from: Android `UserMappers.kt`
///
/// WHY separate mapper files?
/// Same as Android — mappers are pure functions that don't belong in the
/// model classes. They live in the data layer because they know about both
/// DTOs (data layer) and domain models (domain layer).
///
/// Note: Swift's ?? (nil-coalescing) replaces Android's .orZero() / .orEmpty()
enum UserResponseMapper {

    /// UserResponse -> tuple for Core Data upsert.
    /// Equivalent to: UserResponse.toUserEntity()
    ///
    /// Note: Uses `Int` (not `Int32`) to match `UserLocalDataSourceProtocol` signature.
    /// Core Data stores as Int64 internally, but Swift `Int` is the idiomatic choice
    /// for cross-layer tuple types. The conversion happens in `UserLocalDataSource`.
    static func mapToLocal(
        _ response: UserResponse
    ) -> (id: Int, username: String, avatarUrl: String, url: String) {
        return (
            id: response.id ?? 0,
            username: response.login ?? "",
            avatarUrl: response.avatarUrl ?? "",
            url: response.htmlUrl ?? ""
        )
    }

    /// [UserResponse] -> [tuple] batch mapping.
    static func mapToLocalList(
        _ responses: [UserResponse]
    ) -> [(id: Int, username: String, avatarUrl: String, url: String)] {
        responses.map { mapToLocal($0) }
    }

    /// UserEntity -> UserModel (domain model).
    /// Equivalent to: UserEntity.toUserModel()
    static func mapToDomain(_ entity: UserEntity) -> UserModel {
        UserModel(
            id: Int(entity.id),
            username: entity.username ?? "",
            avatarUrl: entity.avatarUrl ?? "",
            url: entity.url ?? ""
        )
    }

    /// [UserEntity] -> [UserModel] batch mapping.
    static func mapToDomainList(_ entities: [UserEntity]) -> [UserModel] {
        entities.map { mapToDomain($0) }
    }
}
