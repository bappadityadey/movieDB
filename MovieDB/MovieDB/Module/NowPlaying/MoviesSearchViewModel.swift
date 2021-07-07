//
//  MoviesSearchViewModel.swift
//  TMDB
//
//  Created by Maksym Shcheglov on 02/10/2019.
//  Copyright © 2019 Maksym Shcheglov. All rights reserved.
//

import Combine

final class MoviesSearchViewModel: MoviesSearchViewModelType {

    private let useCase: MoviesUseCaseType
    private var cancellables: [AnyCancellable] = []

    init(useCase: MoviesUseCaseType) {
        self.useCase = useCase
    }

    func transform(input: MoviesSearchViewModelInput) -> MoviesSearchViewModelOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

//        input.selection
//            .sink(receiveValue: { [unowned self] movieId in self.coordinator?.showMovieDetails(forMovie: movieId, title: "123") })
//            .store(in: &cancellables)
                
        let latestMovies = self.useCase.fetchLatestMovies(with: 1)
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

    private func viewModels(from movies: [Movie]) -> [MovieViewModel] {
        return movies.map({[unowned self] movie in
            return MovieViewModelBuilder.viewModel(from: movie, imageLoader: {[unowned self] movie in self.useCase.loadImage(for: movie, size: .small) })
        })
    }

}
