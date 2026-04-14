//
//  ErrorAlertHelper.swift
//  GitPulse
//

import UIKit

/// Presents error alerts — equivalent to Android's error dialog composable.
enum ErrorAlertHelper {

    static func show(
        error: ErrorState,
        from viewController: UIViewController,
        onDismiss: (() -> Void)? = nil
    ) {
        guard error.hasError else { return }

        let alert = UIAlertController(
            title: "Error",
            message: error.message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onDismiss?()
        })

        viewController.present(alert, animated: true)
    }
}
