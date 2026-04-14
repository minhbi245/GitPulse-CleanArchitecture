//
//  LoadMoreFooterView.swift
//  GitPulse
//

import SnapKit
import UIKit

/// Footer view for pagination loading / retry state.
///
/// Equivalent to Android `LoadState.Loading` / `LoadState.Error` items in the user list:
///   - `.loadingMore` → spinner
///   - `.error`       → retry button
final class LoadMoreFooterView: UICollectionReusableView {

    static let reuseIdentifier = "LoadMoreFooter"

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Retry"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
    }()

    var onRetryTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(state: PaginationLoadState) {
        switch state {
        case .loadingMore:
            activityIndicator.startAnimating()
            retryButton.isHidden = true
        case .error:
            activityIndicator.stopAnimating()
            retryButton.isHidden = false
        case .idle, .refreshing:
            activityIndicator.stopAnimating()
            retryButton.isHidden = true
        }
    }

    private func setupUI() {
        addSubview(activityIndicator)
        addSubview(retryButton)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        retryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    @objc private func retryTapped() {
        onRetryTap?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        retryButton.isHidden = true
        onRetryTap = nil
    }
}
