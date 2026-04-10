//
//  UserDetailsResponse.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// DTO for GitHub user details API response.
/// Maps from: Android `UserDetailsResponse.kt`
struct UserDetailsResponse: Decodable {
    let id: Int?
    let login: String?
    let avatarUrl: String?
    let htmlUrl: String?
    let location: String?
    let followers: Int?
    let following: Int?
    let bio: String?
    let blog: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case location
        case followers
        case following
        case bio
        case blog
        case name
    }
}
