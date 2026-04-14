//
//  ErrorAlertHelper.swift
//  GitPulse
//

import UIKit

/// Presents a standard error alert from any view controller.
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
