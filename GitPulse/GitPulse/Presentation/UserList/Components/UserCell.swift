//
//  UserCell.swift
//  GitPulse
//

import Kingfisher
import SnapKit
import UIKit

/// Collection view cell for a single user row.
///
/// Layout: card view containing avatar (90pt) on the left, then
/// username + separator + URL stacked vertically on the right.
final class UserCell: UICollectionViewCell {

    static let reuseIdentifier = "UserCell"

    // MARK: - UI

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = AppColors.primary.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 45
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemBlue
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    // MARK: - Callbacks

    var onUrlTap: ((String) -> Void)?
    private var currentUrl: String = ""

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with user: UserModel) {
        nameLabel.text = user.username
        urlLabel.text = user.url
        currentUrl = user.url

        let url = URL(string: user.avatarUrl)
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.circle.fill"),
            options: [.transition(.fade(0.25))]
        )
    }

    // MARK: - Layout

    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.size.equalTo(90)
        }

        let textStack = UIStackView(arrangedSubviews: [nameLabel, separatorView, urlLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        cardView.addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(urlTapped))
        urlLabel.isUserInteractionEnabled = true
        urlLabel.addGestureRecognizer(tap)
    }

    @objc private func urlTapped() {
        onUrlTap?(currentUrl)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        nameLabel.text = nil
        urlLabel.text = nil
        onUrlTap = nil
        currentUrl = ""
    }
}
