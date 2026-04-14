//
//  BaseViewModel.swift
//  GitPulse
//

import Combine
import Foundation

/// Base ViewModel with state, loading, error, and one-shot events.
///
/// - `CurrentValueSubject` — hot subject that replays the latest value to new subscribers
/// - `PassthroughSubject` — one-shot events with no replay
@MainActor
class BaseViewModel<UiState, Event> {

    private let stateSubject: CurrentValueSubject<UiState, Never>

    var statePublisher: AnyPublisher<UiState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var state: UiState {
        stateSubject.value
    }

    private let errorSubject = CurrentValueSubject<ErrorState, Never>(.hidden)

    var errorPublisher: AnyPublisher<ErrorState, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    private let loadingSubject = CurrentValueSubject<Bool, Never>(false)

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        loadingSubject.eraseToAnyPublisher()
    }

    var isLoading: Bool {
        loadingSubject.value
    }

    private let eventSubject = PassthroughSubject<Event, Never>()

    var eventPublisher: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    var cancellables = Set<AnyCancellable>()

    init(initialState: UiState) {
        self.stateSubject = CurrentValueSubject(initialState)
    }

    func updateState(_ transform: (UiState) -> UiState) {
        stateSubject.send(transform(stateSubject.value))
    }

    func setState(_ newState: UiState) {
        stateSubject.send(newState)
    }

    func showError(_ error: Error) {
        errorSubject.send(ErrorStateMapper.map(error))
    }

    func hideError() {
        errorSubject.send(.hidden)
    }

    func setLoading(_ loading: Bool) {
        loadingSubject.send(loading)
    }

    func sendEvent(_ event: Event) {
        eventSubject.send(event)
    }

    /// Async work with optional loading overlay and centralized error handling.
    ///
    /// The `task` closure may run off the main actor. Call `await MainActor.run { … }`
    /// (or an `@MainActor` helper) before mutating this view model
    /// (`updateState`, `setState`, `sendEvent`, etc.).
    @discardableResult
    func performTask(
        showLoading: Bool = false,
        onError: ((Error) -> Void)? = nil,
        task: @escaping () async throws -> Void
    ) -> Task<Void, Never> {
        if showLoading { setLoading(true) }

        return Task { [weak self] in
            defer {
                if showLoading {
                    Task { @MainActor in
                        self?.setLoading(false)
                    }
                }
            }
            do {
                try await task()
            } catch {
                await MainActor.run {
                    self?.showError(error)
                    onError?(error)
                }
            }
        }
    }
}
