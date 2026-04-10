//
//  APIClient.swift
//  GitPulse
//
//  Created by Leo Nguyen on 10/4/26.
//

import Foundation

/// HTTP client wrapping URLSession — equivalent to OkHttpClient + Retrofit combined.
///
/// Android mapping:
/// - OkHttpClient.Builder().connectTimeout(30s) -> URLSessionConfiguration.timeoutIntervalForRequest
/// - Retrofit.Builder().baseUrl() -> APIEndpoint handles base URL
/// - ErrorHandlingCallAdapterFactory -> response validation in request()
/// - HttpLoggingInterceptor -> #if DEBUG logging
final class APIClient: @unchecked Sendable {

    private let session: URLSession

    /// - Parameter session: Injectable URLSession for testing.
    nonisolated init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            self.session = URLSession(configuration: config)
        }

    }

    /// Perform a network request and decode the response.
    /// - Parameter endpoint: Type-safe route
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try endpoint.asURLRequest()

        #if DEBUG
        logRequest(urlRequest)
        #endif

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown("Invalid response type")
        }

        #if DEBUG
        logResponse(httpResponse, data: data)
        #endif

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkErrorMapper.mapResponse(
                statusCode: httpResponse.statusCode,
                data: data
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.api(
                code: 0,
                message: "Failed to decode response: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Debug Logging

    private func logRequest(_ request: URLRequest) {
        print("[API] -> \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        print("[API] <- \(response.statusCode) (\(data.count) bytes)")
    }
}
