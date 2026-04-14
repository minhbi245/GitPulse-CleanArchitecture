//
//  AppError.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// Application error types.
///
/// Using `errorDescription` via `LocalizedError` ensures the message is returned
/// correctly when accessed as `Error.localizedDescription`.
enum AppError: LocalizedError, Equatable {
    case api(code: Int, message: String)
    case noConnection
    case unauthorized
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .api(_, let message):
            return message.isEmpty ? "An API error occurred" : message
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Unauthorized access"
        case .unknown(let message):
            return message.isEmpty ? "An unexpected error occurred" : message
        }
    }
}
