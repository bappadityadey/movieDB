//
//  MoviesSearchViewController.swift
//  TMDB
//
//  Created by Maksym Shcheglov on 02/10/2019.
//  Copyright © 2019 Maksym Shcheglov. All rights reserved.
//

import UIKit
import Combine

class MoviesSearchViewController : UIViewController {

    private var cancellables: [AnyCancellable] = []
    private var viewModel: MoviesSearchViewModelType?
    private let selection = PassthroughSubject<Int, Never>()
    private let search = PassthroughSubject<String, Never>()
    private let appear = PassthroughSubject<Void, Never>()
    private let load = PassthroughSubject<Int, Never>()

    @IBOutlet private var loadingView: UIActivityIndicatorView!
    @IBOutlet private var tableView: UITableView!
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifiers.MoviesSearch.searchTextFieldId
        return searchController
    }()
    private lazy var dataSource = makeDataSource()
    
    fileprivate lazy var useCase: MoviesUseCaseType = MoviesUseCase(networkService: servicesProvider.network, imageLoaderService: servicesProvider.imageLoader)

    private let servicesProvider = ServicesProvider.defaultProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MoviesSearchViewModel(useCase: useCase)
        configureUI()
        if let vm = viewModel {
            bind(to: vm)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear.send(())
    }

    private func configureUI() {
        definesPresentationContext = true
        title = NSLocalizedString("Now Playing", comment: "Current Playing Movies")

        tableView.tableFooterView = UIView()
        tableView.registerNib(cellClass: MovieTableViewCell.self)
        tableView.dataSource = dataSource

        navigationItem.searchController = self.searchController
        searchController.isActive = true
    }

    private func bind(to viewModel: MoviesSearchViewModelType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let input = MoviesSearchViewModelInput(appear: appear.eraseToAnyPublisher(),
                                               search: search.eraseToAnyPublisher(),
                                               selection: selection.eraseToAnyPublisher(),
                                               load: load.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }

    private func render(_ state: MoviesSearchState) {
        switch state {
        case .idle:
            loadingView.isHidden = true
            update(with: [], animate: true)
        case .loading:
            loadingView.isHidden = false
            update(with: [], animate: true)
        case .noResults:
            loadingView.isHidden = true
            update(with: [], animate: true)
        case .failure:
            loadingView.isHidden = true
            update(with: [], animate: true)
        case .success(let movies):
            loadingView.isHidden = true
            update(with: movies, animate: true)
        }
    }
}

fileprivate extension MoviesSearchViewController {
    enum Section: CaseIterable {
        case movies
    }

    func makeDataSource() -> UITableViewDiffableDataSource<Section, MovieViewModel> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, movieViewModel in
                guard let cell = tableView.dequeueReusableCell(withClass: MovieTableViewCell.self) else {
                    assertionFailure("Failed to dequeue \(MovieTableViewCell.self)!")
                    return UITableViewCell()
                }
                cell.accessibilityIdentifier = "\(AccessibilityIdentifiers.MoviesSearch.cellId).\(indexPath.row)"
                cell.bind(to: movieViewModel)
                return cell
            }
        )
    }

    func update(with movies: [MovieViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(movies, toSection: .movies)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

extension MoviesSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search.send(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search.send("")
    }
}

extension MoviesSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let movieId = snapshot.itemIdentifiers[indexPath.row].id
        selection.send(movieId)
        self.showMovieDetails(forMovie: movieId)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}
extension MoviesSearchViewController {
    func showMovieDetails(forMovie movieId: Int) {
        if let vc = UIViewController.getViewController(ofType: MovieDetailsViewController.self, fromStoryboardName: "NowPlayingMovies", storyboardId: MovieDetailsViewController.className, bundle: .main) {
            let vm = MovieDetailsViewModel(movieId: movieId, useCase: useCase)
            vc.viewModel = vm
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
