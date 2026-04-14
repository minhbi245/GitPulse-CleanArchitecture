//
//  UserCountryView.swift
//  GitPulse
//

import SnapKit
import UIKit

/// Country display with location icon.
final class UserCountryView: UIView {

    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "location.fill"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(country: String) {
        isHidden = country.isEmpty
        countryLabel.text = country
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [iconImageView, countryLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}
