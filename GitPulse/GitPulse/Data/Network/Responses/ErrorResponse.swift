//
//  ErrorResponse.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// DTO for GitHub API error responses.
/// Maps from: Android `ErrorResponse.kt`
struct ErrorResponse: Decodable {
    let message: String?
    let documentationUrl: String?

    enum CodingKeys: String, CodingKey {
        case message
        case documentationUrl = "documentation_url"
    }
}
