//
//  UserResponseMapper.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation

/// Maps network DTOs to persistence/domain types.
///
/// Mappers are pure functions that live in the data layer because they know about
/// both DTOs (data layer) and domain models (domain layer).
///
/// Swift's `??` (nil-coalescing) handles optional fields from the API.
enum UserResponseMapper {

    /// UserResponse -> tuple for Core Data upsert.
    ///
    /// Uses `Int` (not `Int32`) to match `UserLocalDataSourceProtocol` signature.
    /// Core Data stores as Int64 internally; the conversion happens in `UserLocalDataSource`.
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

    /// UserModel -> tuple for Core Data upsert.
    /// Used by `PaginationManager` which receives domain models from the use case
    /// rather than raw DTOs.
    static func mapToLocal(
        _ model: UserModel
    ) -> (id: Int, username: String, avatarUrl: String, url: String) {
        return (
            id: model.id,
            username: model.username,
            avatarUrl: model.avatarUrl,
            url: model.url
        )
    }

    /// [UserModel] -> [tuple] batch mapping.
    static func mapToLocalList(
        _ models: [UserModel]
    ) -> [(id: Int, username: String, avatarUrl: String, url: String)] {
        models.map { mapToLocal($0) }
    }

    /// UserEntity -> UserModel (domain model).
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
