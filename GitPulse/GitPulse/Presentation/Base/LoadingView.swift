//
//  LoadingView.swift
//  GitPulse
//

import SnapKit
import UIKit

/// Full-screen loading overlay with a fade-in/out animation.
final class LoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func show(in parentView: UIView) {
        if superview == nil {
            parentView.addSubview(self)
            snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        alpha = 0
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        })
    }
}
