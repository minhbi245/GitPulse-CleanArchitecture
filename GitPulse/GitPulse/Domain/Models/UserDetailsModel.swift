/// Domain model for detailed GitHub user info.
/// Maps from: Android `UserDetailsModel.kt`
struct UserDetailsModel: Equatable {
    let username: String
    let avatarUrl: String
    let country: String
    let followers: Int
    let following: Int
    let url: String

    init(
        username: String = "",
        avatarUrl: String = "",
        country: String = "",
        followers: Int = 0,
        following: Int = 0,
        url: String = ""
    ) {
        self.username = username
        self.avatarUrl = avatarUrl
        self.country = country
        self.followers = followers
        self.following = following
        self.url = url
    }
}
