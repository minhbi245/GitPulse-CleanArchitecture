//
//  UserResponse.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// DTO for GitHub user list API response.
///
/// Only includes fields we actually use (YAGNI).
struct UserResponse: Decodable {
    let id: Int?
    let login: String?
    let avatarUrl: String?
    let htmlUrl: String?
    let type: String?
    let siteAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case type
        case siteAdmin = "site_admin"
    }
}
