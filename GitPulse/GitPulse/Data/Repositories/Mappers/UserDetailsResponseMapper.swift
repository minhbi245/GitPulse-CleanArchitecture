//
//  UserDetailsResponseMapper.swift
//  GitPulse
//
//  Created by Leo Nguyen on 11/4/26.
//

import Foundation

/// Maps user details network DTOs to domain models.
enum UserDetailsResponseMapper {

    /// UserDetailsResponse -> UserDetailsModel.
    static func mapToDomain(_ response: UserDetailsResponse) -> UserDetailsModel {
        UserDetailsModel(
            username: response.login ?? "",
            avatarUrl: response.avatarUrl ?? "",
            country: response.location ?? "",
            followers: response.followers ?? 0,
            following: response.following ?? 0,
            url: response.htmlUrl ?? ""
        )
    }
}
