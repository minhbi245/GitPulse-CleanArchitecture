//
//  NetworkErrorMapperTests.swift
//  GitPulseTests
//
//  Equivalent to Android `ErrorMappersKtTest` + `ErrorHandlingCallbackTest`.
//

import XCTest
@testable import GitPulse

final class NetworkErrorMapperTests: XCTestCase {

    // MARK: - mapResponse

    func testMapResponse_401_returnsUnauthorized() {
        let error = NetworkErrorMapper.mapResponse(statusCode: 401, data: nil)
        XCTAssertEqual(error, .unauthorized)
    }

    func testMapResponse_withErrorBody_returnsApiError() {
        let json = #"{"message": "Not Found"}"#
        let data = json.data(using: .utf8)

        let error = NetworkErrorMapper.mapResponse(statusCode: 404, data: data)

        XCTAssertEqual(error, .api(code: 404, message: "Not Found"))
    }

    func testMapResponse_withoutBody_returnsGenericApiError() {
        let error = NetworkErrorMapper.mapResponse(statusCode: 500, data: nil)
        XCTAssertEqual(error, .api(code: 500, message: "HTTP Error 500"))
    }

    // MARK: - mapError

    func testMapError_noConnection_returnsNoConnection() {
        let urlError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: nil
        )

        XCTAssertEqual(NetworkErrorMapper.mapError(urlError), .noConnection)
    }

    func testMapError_timeout_returnsNoConnection() {
        let urlError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut,
            userInfo: nil
        )

        XCTAssertEqual(NetworkErrorMapper.mapError(urlError), .noConnection)
    }

    func testMapError_unknownError_returnsUnknown() {
        let error = NSError(domain: "test", code: 999, userInfo: nil)

        let result = NetworkErrorMapper.mapError(error)

        guard case .unknown = result else {
            XCTFail("Expected .unknown, got \(result)")
            return
        }
    }
}
