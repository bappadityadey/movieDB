//
//  MoviesSearchViewModel.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Combine

final class MoviesListViewModel: MoviesSearchViewModelType {
    var totalPages: Int = 1

    private let useCase: MoviesUseCaseType
    private let page: Int
    private var cancellables: [AnyCancellable] = []

    init(useCase: MoviesUseCaseType, page: Int) {
        self.useCase = useCase
        self.page = page
    }
    
    func fetchNextPageData(page: Int) -> MoviesSearchViewModelOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
                
        let latestMovies = self.useCase.fetchLatestMovies(with: page)
            .map({ result -> MoviesSearchState in
                switch result {
                case .success(let latestMovies) where latestMovies.items.isEmpty: return .noResults
                case .success(let latestMovies): return .success(self.viewModels(from: latestMovies.items))
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        
        let initialState: MoviesSearchViewModelOuput = .just(.idle)
        return Publishers.Merge(initialState, latestMovies).removeDuplicates().eraseToAnyPublisher()
    }
    
    func searchMovies(input: MoviesListViewModelInput) -> MoviesSearchViewModelOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
                
        let searchInput = input.search
            .debounce(for: .milliseconds(300), scheduler: Scheduler.mainScheduler)
            .removeDuplicates()
        let movies = searchInput
            .filter({ !$0.isEmpty })
            .flatMapLatest({[unowned self] query in self.useCase.searchMovies(with: query) })
            .map({ result -> MoviesSearchState in
                switch result {
                case .success(let movies) where movies.items.isEmpty: return .noResults
                case .success(let movies): return .success(self.viewModels(from: movies.items))
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        
        let initialState: MoviesSearchViewModelOuput = .just(.idle)
        let emptySearchString: MoviesSearchViewModelOuput = searchInput.filter({ $0.isEmpty }).map({ _ in .idle }).eraseToAnyPublisher()
        let idle: MoviesSearchViewModelOuput = Publishers.Merge(initialState, emptySearchString).eraseToAnyPublisher()

        return Publishers.Merge(idle, movies).removeDuplicates().eraseToAnyPublisher()
    }

    func transform(input: MoviesListViewModelInput) -> MoviesSearchViewModelOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
                
        let latestMovies = self.useCase.fetchLatestMovies(with: page)
            .map({ result -> MoviesSearchState in
                switch result {
                case .success(let latestMovies) where latestMovies.items.isEmpty: return .noResults
                case .success(let latestMovies):
                    self.totalPages = latestMovies.totalPages
                    return .success(self.viewModels(from: latestMovies.items))
                case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        
        let initialState: MoviesSearchViewModelOuput = .just(.idle)
        return Publishers.Merge(initialState, latestMovies).removeDuplicates().eraseToAnyPublisher()
    }

    private func viewModels(from movies: [Movie]) -> [MovieViewModel] {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else {
            return []
        }
        MovieListHandler.saveCurrentMovieList(movies, moc: context)
        return movies.map({[unowned self] movie in
            return MovieViewModelBuilder.viewModel(from: movie, imageLoader: {[unowned self] movie in self.useCase.loadImage(for: movie, size: .small) })
        })
    }

}
