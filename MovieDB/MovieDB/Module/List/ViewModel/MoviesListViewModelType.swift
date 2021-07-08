//
//  MoviesSearchViewModelType.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Combine

struct MoviesListViewModelInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    // triggered when the search query is updated
    let search: AnyPublisher<String, Never>
    /// called when the user selected an item from the list
    let selection: AnyPublisher<Int, Never>
    /// called when the screen is loaded
    let load: AnyPublisher<Int, Never>
}

enum MoviesSearchState {
    case idle
    case loading
    case success([MovieViewModel])
    case noResults
    case failure(Error)
}

extension MoviesSearchState: Equatable {
    static func == (lhs: MoviesSearchState, rhs: MoviesSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhsMovies), .success(let rhsMovies)): return lhsMovies == rhsMovies
        case (.noResults, .noResults): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

typealias MoviesListViewModelOuput = AnyPublisher<MoviesSearchState, Never>

protocol MoviesListViewModelType {
    func transform(input: MoviesListViewModelInput) -> MoviesListViewModelOuput
    func offlineMoviesList(input: MoviesListViewModelInput) -> MoviesListViewModelOuput
    func searchMovies(input: MoviesListViewModelInput) -> MoviesListViewModelOuput
    func fetchNextPageData(page: Int) -> MoviesListViewModelOuput
    var totalPages: Int { get set }
}
