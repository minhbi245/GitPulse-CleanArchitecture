//
//  ErrorState.swift
//  GitPulse
//

import Foundation

/// UI error state — equivalent to Android's `ErrorUiState` + exception mappers.
///
/// Android uses `@StringRes` for strings compiled into `R`; iOS uses displayable
/// `String` values (or `NSLocalizedString` at call sites).
struct ErrorState: Equatable {
    let message: String
    let isVisible: Bool

    static let hidden = ErrorState(message: "", isVisible: false)

    /// Equivalent to Android `hasError()`.
    var hasError: Bool { isVisible && !message.isEmpty }
}

/// Maps errors to user-facing state — equivalent to `Throwable?.toErrorUiState()`.
enum ErrorStateMapper {
    static func map(_ error: Error) -> ErrorState {
        if let appError = error as? AppError {
            switch appError {
            case .api(_, let message):
                return ErrorState(
                    message: message.isEmpty ? "An error occurred" : message,
                    isVisible: true
                )
            case .noConnection:
                return ErrorState(
                    message: "No internet connection. Please check your network.",
                    isVisible: true
                )
            case .unauthorized:
                return ErrorState(
                    message: "Unauthorized. Please check your credentials.",
                    isVisible: true
                )
            case .unknown(let message):
                return ErrorState(
                    message: message.isEmpty ? "Something went wrong" : message,
                    isVisible: true
                )
            }
        }
        return ErrorState(
            message: "Something went wrong. Please try again.",
            isVisible: true
        )
    }
}
