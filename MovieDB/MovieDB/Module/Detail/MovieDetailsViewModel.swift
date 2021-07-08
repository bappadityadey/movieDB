//
//  MovieDetailsViewModel.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Combine

class MovieDetailsViewModel: MovieDetailsViewModelType {

    private let movieId: Int
    private let useCase: MoviesUseCaseType

    init(movieId: Int, useCase: MoviesUseCaseType) {
        self.movieId = movieId
        self.useCase = useCase
    }

    func transform(input: MovieDetailsViewModelInput) -> MovieDetailsViewModelOutput {
        let movieDetails = input.appear
            .flatMap({[unowned self] _ in self.useCase.movieDetails(with: self.movieId) })
            .map({ result -> MovieDetailsState in
                switch result {
                    case .success(let movie): return .success(self.viewModel(from: movie))
                    case .failure(let error): return .failure(error)
                }
            })
            .eraseToAnyPublisher()
        let loading: MovieDetailsViewModelOutput = input.appear.map({_ in .loading }).eraseToAnyPublisher()

        return Publishers.Merge(loading, movieDetails).removeDuplicates().eraseToAnyPublisher()
    }

    private func viewModel(from movie: Movie) -> MovieViewModel {
        return MovieViewModelBuilder.viewModel(from: movie, imageLoader: {[unowned self] movie in self.useCase.loadImage(for: movie, size: .original) })
    }
    
    func addToFavourite() {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else {
            return
        }
        MovieDetailsHandler.addMovieInfoObjectToSavedItems(movieId, moc: context)
    }
    
    func removeFromFavourite() {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else {
            return
        }
        MovieDetailsHandler.removeMovieInfoObjectFromSavedItems(movieId, moc: context)
    }
    
    func isMovieExistsInFavourites() -> Bool {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else {
            return false
        }
        return MovieDetailsHandler.isMovieExistsInFavourites(movieId, moc: context)
    }
}
