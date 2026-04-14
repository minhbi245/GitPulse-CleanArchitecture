//
//  UserDetailsCardView.swift
//  GitPulse
//

import Kingfisher
import SnapKit
import UIKit

/// User card with avatar, username, and country displayed vertically centered.
final class UserDetailsCardView: UIView {

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.layer.borderWidth = 2
        iv.layer.borderColor = AppColors.primary.cgColor
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let countryView = UserCountryView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(username: String, avatarUrl: String, country: String) {
        usernameLabel.text = username
        countryView.configure(country: country)

        if let url = URL(string: avatarUrl) {
            avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill"),
                options: [.transition(.fade(0.25))]
            )
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, usernameLabel, countryView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(120)
        }
    }
}
