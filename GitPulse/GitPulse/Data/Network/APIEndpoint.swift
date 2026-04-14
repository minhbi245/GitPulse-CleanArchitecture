//
//  APIEndpoint.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// Type-safe API route definitions.
///
/// Each case is a distinct endpoint; associated values carry the route parameters.
enum APIEndpoint {
    case getUsers(perPage: Int, since: Int)
    case getUserDetails(username: String)

    // MARK: - Request Components

    private var baseURL: String {
        "https://api.github.com"
    }

    var method: String {
        switch self {
        case .getUsers, .getUserDetails:
            return "GET"
        }
    }

    /// Path component — equivalent to @GET("/users") and @Path("username")
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUserDetails(let username):
            let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
            return "/users/\(encoded)"
        }
    }

    /// Query parameters — equivalent to @Query annotations
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getUsers(let perPage, let since):
            return [
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "since", value: "\(since)"),
            ]
        case .getUserDetails:
            return nil
        }
    }

    /// Build the full URLRequest — combines base URL, path, query, method, and headers.
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw AppError.api(code: 0, message: "Invalid URL: \(baseURL + path)")
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw AppError.api(code: 0, message: "Failed to construct URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // Equivalent to HeaderInterceptor adding these headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
