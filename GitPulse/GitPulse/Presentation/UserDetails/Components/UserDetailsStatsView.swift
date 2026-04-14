//
//  UserDetailsStatsView.swift
//  GitPulse
//

import SnapKit
import UIKit

/// Followers/following stats card with a vertical divider between the two columns.
final class UserDetailsStatsView: UIView {

    private let followersValueLabel = UserDetailsStatsView.makeValueLabel()
    private let followersTitleLabel = UserDetailsStatsView.makeTitleLabel("Follower")
    private let followingValueLabel = UserDetailsStatsView.makeValueLabel()
    private let followingTitleLabel = UserDetailsStatsView.makeTitleLabel("Following")

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(followers: String, following: String) {
        followersValueLabel.text = followers
        followingValueLabel.text = following
    }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12

        let followersStack = UIStackView(arrangedSubviews: [followersValueLabel, followersTitleLabel])
        followersStack.axis = .vertical
        followersStack.alignment = .center
        followersStack.spacing = 4

        let followingStack = UIStackView(arrangedSubviews: [followingValueLabel, followingTitleLabel])
        followingStack.axis = .vertical
        followingStack.alignment = .center
        followingStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [followersStack, divider, followingStack])
        mainStack.axis = .horizontal
        mainStack.distribution = .fill
        mainStack.alignment = .center
        mainStack.spacing = 16

        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        followersStack.snp.makeConstraints { make in
            make.width.equalTo(followingStack)
        }

        divider.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(40)
        }
    }

    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }

    private static func makeTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }
}
