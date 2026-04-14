//
//  UserBlogView.swift
//  GitPulse
//

import SnapKit
import UIKit

/// Blog link card — tappable to open the user's blog URL.
final class UserBlogView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Blog"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(url: String) {
        isHidden = url.isEmpty
        urlLabel.text = url
    }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        isUserInteractionEnabled = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, urlLabel])
        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        onTap?()
    }
}
