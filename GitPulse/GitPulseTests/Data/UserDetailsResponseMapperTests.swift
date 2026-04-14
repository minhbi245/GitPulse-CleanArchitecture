//
//  UserDetailsResponseMapperTests.swift
//  GitPulseTests
//
//  Equivalent to Android `UserDetailsMappersKtTest`.
//

import XCTest
@testable import GitPulse

final class UserDetailsResponseMapperTests: XCTestCase {

    func testMapToDomain_withValidResponse_returnsCorrectModel() {
        let response = UserDetailsResponse(
            id: 1, login: "mojombo",
            avatarUrl: "https://avatar.url",
            htmlUrl: "https://github.com/mojombo",
            location: "San Francisco",
            followers: 100, following: 50,
            bio: nil, blog: nil, name: nil
        )

        let result = UserDetailsResponseMapper.mapToDomain(response)

        XCTAssertEqual(result.username, "mojombo")
        XCTAssertEqual(result.avatarUrl, "https://avatar.url")
        XCTAssertEqual(result.country, "San Francisco")
        XCTAssertEqual(result.followers, 100)
        XCTAssertEqual(result.following, 50)
        XCTAssertEqual(result.url, "https://github.com/mojombo")
    }

    func testMapToDomain_withNilFields_returnsDefaults() {
        let response = UserDetailsResponse(
            id: nil, login: nil, avatarUrl: nil, htmlUrl: nil,
            location: nil, followers: nil, following: nil,
            bio: nil, blog: nil, name: nil
        )

        let result = UserDetailsResponseMapper.mapToDomain(response)

        XCTAssertEqual(result.username, "")
        XCTAssertEqual(result.avatarUrl, "")
        XCTAssertEqual(result.country, "")
        XCTAssertEqual(result.followers, 0)
        XCTAssertEqual(result.following, 0)
        XCTAssertEqual(result.url, "")
    }
}
