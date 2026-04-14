//
//  UserModel.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

/// Domain model representing a GitHub user in list view.
/// Maps from: Android `UserModel.kt` (data class -> struct)
nonisolated struct UserModel: Hashable, Identifiable, Sendable {
    let id: Int
    let username: String
    let avatarUrl: String
    let url: String

    init(
        id: Int = 0,
        username: String = "",
        avatarUrl: String = "",
        url: String = ""
    ) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.url = url
    }
}
