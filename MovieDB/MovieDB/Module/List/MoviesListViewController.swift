//
//  MoviesSearchViewController.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import UIKit
import Combine

class MoviesListViewController : UIViewController {
    
    var currentPage: Int = 1
    var isSearching: Bool = false
    var isFavouriteSegment: Bool = false

    private var cancellables: [AnyCancellable] = []
    private var viewModel: MoviesListViewModelType?
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
        return searchController
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Now Playing", "Favourites"])
        segmentControl.tintColor = .label
        return segmentControl
    }()
    
    private lazy var dataSource = makeDataSource()
    private var moviesList = [MovieViewModel]()
    
    private lazy var useCase: MoviesUseCaseType = MoviesUseCase(networkService: servicesProvider.network, imageLoaderService: servicesProvider.imageLoader)

    private let servicesProvider = ServicesProvider.defaultProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MoviesListViewModel(useCase: useCase, page: currentPage)
        configureUI()
        if let vm = viewModel {
            bind(to: vm)
        }
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        let output = viewModel?.fetchNextPageData(page: currentPage)
        output?.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear.send(())
        showFavouriteMovies()
    }

    private func configureUI() {
        definesPresentationContext = true

        tableView.tableFooterView = UIView()
        tableView.registerNib(cellClass: MovieTableViewCell.self)
        tableView.dataSource = dataSource

        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.isActive = true
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        self.navigationItem.titleView = segmentControl
    }
    
    @objc
    func segmentedValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            isFavouriteSegment = true
            navigationItem.searchController = nil
            showFavouriteMovies()
        } else {
            isFavouriteSegment = false
            navigationItem.searchController = self.searchController
            update(with: [])
        }
    }
    
    private func showFavouriteMovies() {
        guard isFavouriteSegment else {
            return
        }
        let offlineMovies = MovieListHandler.fetchFavouritesMovieList(in: (AppDelegate.appDelegateInstance?.backgroundContext())!)
        let result = offlineMovies.map({[unowned self] movie in
            return MovieViewModelBuilder.viewModel(from: movie, imageLoader: {[unowned self] movie in self.useCase.loadImage(for: movie, size: .small) })
        })
        render(.success(result))
    }

    private func bind(to viewModel: MoviesListViewModelType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        var output: MoviesListViewModelOuput?
        let input = MoviesListViewModelInput(appear: appear.eraseToAnyPublisher(),
                                               search: search.eraseToAnyPublisher(),
                                               selection: selection.eraseToAnyPublisher(),
                                               load: load.eraseToAnyPublisher())
        
        if AppDelegate.appDelegateInstance?.isReachable == false {
            output = viewModel.offlineMoviesList(input: input)
        } else {
            output = viewModel.transform(input: input)
        }
        output?.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)

        let searchOutput = viewModel.searchMovies(input: input)

        searchOutput.sink(receiveValue: {[unowned self] state in
            self.render(state, isSearch: true)
        }).store(in: &cancellables)
    }

    private func render(_ state: MoviesSearchState, isSearch: Bool = false) {
        switch state {
        case .idle:
            loadingView.isHidden = true
            update(with: [])
        case .loading:
            loadingView.isHidden = false
            update(with: [])
        case .noResults:
            loadingView.isHidden = true
            update(with: [])
        case .failure:
            loadingView.isHidden = true
            update(with: [])
        case .success(let movies):
            loadingView.isHidden = true
            update(with: movies)
        }
    }
}

fileprivate extension MoviesListViewController {
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
                cell.bind(to: movieViewModel)
                return cell
            }
        )
    }

    func update(with movies: [MovieViewModel]) {
        if !isSearching {
            moviesList.append(contentsOf: movies)
        }
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems((self.isSearching || self.isFavouriteSegment) ? movies : self.moviesList.uniqueElements(), toSection: .movies)
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            update(with: [])
        } else {
            isSearching = true
            search.send(searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        update(with: [])
        //search.send("")
    }
}

extension MoviesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let movieId = snapshot.itemIdentifiers[indexPath.row].id
        selection.send(movieId)
        self.showMovieDetails(forMovie: movieId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = dataSource.snapshot().itemIdentifiers.count - 1
        if indexPath.row == lastItem, currentPage < (self.viewModel?.totalPages ?? 1) - 1, !isSearching {
            loadMoreItemsForList()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}
extension MoviesListViewController {
    func showMovieDetails(forMovie movieId: Int) {
        if let vc = UIViewController.getViewController(ofType: MovieDetailsViewController.self, fromStoryboardName: "MoviesDB", storyboardId: MovieDetailsViewController.className, bundle: .main) {
            let vm = MovieDetailsViewModel(movieId: movieId, useCase: useCase)
            vc.viewModel = vm
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
