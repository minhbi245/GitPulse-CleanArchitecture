//
//  UserListViewController.swift
//  GitPulse
//

import Combine
import SnapKit
import UIKit

/// User list screen — equivalent to Android `UserListScreen` + `UserListContent` composables.
///
/// Composition:
///   - `UICollectionView` + `UICollectionViewCompositionalLayout` ≈ `LazyVerticalGrid`
///   - `UICollectionViewDiffableDataSource`                       ≈ `items(count, key)`
///   - `UIRefreshControl`                                         ≈ `PullToRefreshBox`
///   - `LoadingView` + error alert from `BaseViewModel` bindings
final class UserListViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: UserListViewModel
    private var cancellables = Set<AnyCancellable>()

    /// Routes user-selection events to the coordinator. Weak to avoid a retain cycle.
    weak var coordinatorDelegate: UserListCoordinatorDelegate?

    // MARK: - UI

    private let loadingView = LoadingView()

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)
        cv.register(
            LoadMoreFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadMoreFooterView.reuseIdentifier
        )
        cv.delegate = self
        return cv
    }()

    private let refreshControl = UIRefreshControl()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, UserModel> = {
        let ds = UICollectionViewDiffableDataSource<Section, UserModel>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, user in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserCell.reuseIdentifier,
                for: indexPath
            ) as! UserCell
            cell.configure(with: user)
            cell.onUrlTap = { [weak self] url in
                self?.openURL(url)
            }
            return cell
        }

        ds.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadMoreFooterView.reuseIdentifier,
                for: indexPath
            ) as! LoadMoreFooterView
            footer.configure(state: self?.viewModel.paginationState ?? .idle)
            footer.onRetryTap = { [weak self] in self?.viewModel.retryLoadNextPage() }
            return footer
        }

        return ds
    }()

    private nonisolated enum Section: Hashable, Sendable { case main }

    // MARK: - Init

    init(viewModel: UserListViewModel) {
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
        viewModel.loadInitialData()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "GitHub Users"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

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

        viewModel.$users
            .sink { [weak self] users in
                self?.applySnapshot(users: users)
            }
            .store(in: &cancellables)

        viewModel.$paginationState
            .sink { [weak self] _ in
                self?.reloadFooterIfVisible()
            }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.isRefreshing)
            .removeDuplicates()
            .sink { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
    }

    // MARK: - Data

    private func applySnapshot(users: [UserModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        let isFirstPaint = dataSource.snapshot().itemIdentifiers.isEmpty
        dataSource.apply(snapshot, animatingDifferences: !isFirstPaint)
    }

    private func reloadFooterIfVisible() {
        let kind = UICollectionView.elementKindSectionFooter
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            if let footer = collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? LoadMoreFooterView {
                footer.configure(state: viewModel.paginationState)
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.refresh()
    }

    private func handleEvent(_ event: UserListEvent) {
        switch event {
        case .navigateToDetails(let username, let avatarUrl, let url):
            coordinatorDelegate?.userListDidSelectUser(
                username: username,
                avatarUrl: avatarUrl,
                url: url
            )
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Layout

    /// Adaptive grid: 1 column compact (`iPhone portrait`), 2 columns regular (`iPad`, `iPhone Plus landscape`).
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let isCompact = environment.traitCollection.horizontalSizeClass == .compact
            let columns = isCompact ? 1 : 2

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .estimated(114)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(114)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16, leading: 16, bottom: 16, trailing: 16
            )

            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]

            return section
        }
    }
}

// MARK: - UICollectionViewDelegate

extension UserListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.selectUser(user)
    }

    /// Infinite scroll — trigger next page when within two screens of the bottom.
    /// Equivalent to Paging3 prefetch behavior.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        guard contentHeight > 0 else { return }

        if offsetY > contentHeight - frameHeight * 2 {
            viewModel.loadNextPage()
        }
    }
}
