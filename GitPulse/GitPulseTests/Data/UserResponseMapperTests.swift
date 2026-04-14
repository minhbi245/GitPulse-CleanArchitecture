//
//  UserResponseMapperTests.swift
//  GitPulseTests
//
//  Equivalent to Android `UserMappersKtTest`.
//

import XCTest
@testable import GitPulse

final class UserResponseMapperTests: XCTestCase {

    func testMapToLocal_withValidResponse_returnsCorrectTuple() {
        let response = UserResponse(
            id: 1, login: "mojombo",
            avatarUrl: "https://avatar.url",
            htmlUrl: "https://github.com/mojombo",
            type: nil, siteAdmin: nil
        )

        let result = UserResponseMapper.mapToLocal(response)

        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.username, "mojombo")
        XCTAssertEqual(result.avatarUrl, "https://avatar.url")
        XCTAssertEqual(result.url, "https://github.com/mojombo")
    }

    func testMapToLocal_withNilFields_returnsDefaults() {
        let response = UserResponse(
            id: nil, login: nil, avatarUrl: nil,
            htmlUrl: nil, type: nil, siteAdmin: nil
        )

        let result = UserResponseMapper.mapToLocal(response)

        XCTAssertEqual(result.id, 0)
        XCTAssertEqual(result.username, "")
        XCTAssertEqual(result.avatarUrl, "")
        XCTAssertEqual(result.url, "")
    }

    func testMapToLocalList_mapsAllItems() {
        // Explicit `Int` annotation prevents Swift from promoting `i` to `Int?`
        // (matching UserResponse.init(id: Int?)), which would make the login
        // string interpolate as "userOptional(0)" instead of "user0".
        let responses: [UserResponse] = (0..<5).map { (i: Int) in
            UserResponse(
                id: i, login: "user\(i)",
                avatarUrl: nil, htmlUrl: nil,
                type: nil, siteAdmin: nil
            )
        }

        let result = UserResponseMapper.mapToLocalList(responses)

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0].id, 0)
        XCTAssertEqual(result[0].username, "user0")
        XCTAssertEqual(result[4].id, 4)
        XCTAssertEqual(result[4].username, "user4")
    }
}
