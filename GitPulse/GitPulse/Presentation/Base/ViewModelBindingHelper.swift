//
//  ViewModelBindingHelper.swift
//  GitPulse
//

import Combine
import UIKit

extension UIViewController {

    /// Binds loading stream to a `LoadingView` — analogous to `collectAsStateWithLifecycle` for loading.
    func bindLoading(
        _ publisher: AnyPublisher<Bool, Never>,
        loadingView: LoadingView,
        cancellables: inout Set<AnyCancellable>
    ) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    loadingView.show(in: self.view)
                } else {
                    loadingView.hide()
                }
            }
            .store(in: &cancellables)
    }

    /// Presents an alert when `ErrorState` becomes visible — call `onDismiss` to clear VM error if needed.
    func bindError(
        _ publisher: AnyPublisher<ErrorState, Never>,
        onDismiss: @escaping () -> Void,
        cancellables: inout Set<AnyCancellable>
    ) {
        publisher
            .receive(on: DispatchQueue.main)
            .filter(\.hasError)
            .sink { [weak self] errorState in
                guard let self else { return }
                ErrorAlertHelper.show(
                    error: errorState,
                    from: self,
                    onDismiss: onDismiss
                )
            }
            .store(in: &cancellables)
    }
}
