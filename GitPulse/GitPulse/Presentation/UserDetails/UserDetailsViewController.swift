//
//  UserDetailsViewController.swift
//  GitPulse
//

import Combine
import SnapKit
import UIKit

/// User details screen — equivalent to Android `UserDetailsScreen` + `UserDetailsContent`.
///
/// Adaptive layout (mirrors Android's `windowHeightSizeClass == COMPACT` branch):
/// - Regular height (portrait): card → stats → blog stacked vertically
/// - Compact height (landscape): card + stats side-by-side, blog below
final class UserDetailsViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: UserDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let loadingView = LoadingView()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        return sv
    }()

    /// Holds card + stats side-by-side in landscape; repopulated on trait changes.
    private let horizontalStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        sv.alignment = .center
        return sv
    }()

    private let cardView = UserDetailsCardView()
    private let statsView = UserDetailsStatsView()
    private let blogView = UserBlogView()

    // MARK: - Init

    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    /// Re-layout for rotation — equivalent to Compose re-running on `windowHeightSizeClass` change.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            updateLayoutForTraits()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        title = "User Details"
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }

        blogView.onTap = { [weak self] in
            self?.viewModel.openBlog()
        }

        updateLayoutForTraits()
    }

    /// Adaptive layout — mirrors Android's `isHeightCompact` Row/Column switch.
    private func updateLayoutForTraits() {
        [cardView, statsView, blogView].forEach { $0.removeFromSuperview() }
        horizontalStack.arrangedSubviews.forEach { horizontalStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0); $0.removeFromSuperview() }

        let isCompactHeight = traitCollection.verticalSizeClass == .compact

        if isCompactHeight {
            horizontalStack.addArrangedSubview(cardView)
            horizontalStack.addArrangedSubview(statsView)
            contentStackView.addArrangedSubview(horizontalStack)
        } else {
            contentStackView.addArrangedSubview(cardView)
            contentStackView.addArrangedSubview(statsView)
        }

        contentStackView.addArrangedSubview(blogView)
    }

    // MARK: - Binding

    private func bindViewModel() {
        bindLoading(
            viewModel.isLoadingPublisher,
            loadingView: loadingView,
            cancellables: &cancellables
        )

        bindError(
            viewModel.errorPublisher,
            onDismiss: { [weak self] in self?.viewModel.hideError() },
            cancellables: &cancellables
        )

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)

        viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: UserDetailUiState) {
        cardView.configure(
            username: state.username,
            avatarUrl: state.avatarUrl,
            country: state.country
        )
        statsView.configure(
            followers: state.followers,
            following: state.following
        )
        blogView.configure(url: state.url)
    }

    private func handleEvent(_ event: UserDetailsEvent) {
        switch event {
        case .openBlog(let url):
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }
    }
}
