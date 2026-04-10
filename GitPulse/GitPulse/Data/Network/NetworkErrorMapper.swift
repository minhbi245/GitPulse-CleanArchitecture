//
//  NetworkErrorMapper.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// Maps URLSession responses/errors to domain AppError type.
/// Maps from: Android `ErrorMappers.kt` + `ErrorHandlingCallback.kt`
enum NetworkErrorMapper {

    /// Map HTTP response + data to AppError when status code indicates failure.
    static func mapResponse(statusCode: Int, data: Data?) -> AppError {
        if statusCode == 401 {
            return .unauthorized
        }

        if let data = data,
           let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return .api(
                code: statusCode,
                message: errorResponse.message ?? ""
            )
        }

        return .api(code: statusCode, message: "HTTP Error \(statusCode)")
    }

    /// Map URLSession transport errors to AppError.
    static func mapError(_ error: Error) -> AppError {
        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorTimedOut:
            return .noConnection
        default:
            if let appError = error as? AppError {
                return appError
            }
            return .unknown(error.localizedDescription)
        }
    }
}
