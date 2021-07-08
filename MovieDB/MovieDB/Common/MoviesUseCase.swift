//
//  MoviesUseCase.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation
import Combine
import UIKit.UIImage

protocol MoviesUseCaseType: AutoMockable {

    /// Runs movies search with a query string
    func searchMovies(with name: String) -> AnyPublisher<Result<Movies, Error>, Never>

    /// Fetches details for movie with specified id
    func movieDetails(with id: Int) -> AnyPublisher<Result<Movie, Error>, Never>

    // Loads image for the given movie
    func loadImage(for movie: Movie, size: ImageSize) -> AnyPublisher<UIImage?, Never>
    
    // Fetches latest playing movies
    func fetchLatestMovies(with page: Int) -> AnyPublisher<Result<Movies, Error>, Never>
    
    func loadOfflineMoviesList() -> AnyPublisher<[Movie]?, Never>
    func loadOfflineMovie(with id: Int) -> AnyPublisher<Movie?, Never>
}

final class MoviesUseCase: MoviesUseCaseType {

    private let networkService: NetworkServiceType
    private let imageLoaderService: ImageLoaderServiceType

    init(networkService: NetworkServiceType, imageLoaderService: ImageLoaderServiceType) {
        self.networkService = networkService
        self.imageLoaderService = imageLoaderService
    }

    func searchMovies(with name: String) -> AnyPublisher<Result<Movies, Error>, Never> {
        return networkService
            .load(Resource<Movies>.movies(query: name))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Movies, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }

    func movieDetails(with id: Int) -> AnyPublisher<Result<Movie, Error>, Never> {
        return networkService
            .load(Resource<Movie>.details(movieId: id))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Movie, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }

    func loadImage(for movie: Movie, size: ImageSize) -> AnyPublisher<UIImage?, Never> {
        return Deferred { return Just(movie.poster_path) }
        .flatMap({[unowned self] poster -> AnyPublisher<UIImage?, Never> in
            guard let poster = movie.poster_path else { return .just(nil) }
            let url = size.url.appendingPathComponent(poster)
            return self.imageLoaderService.loadImage(from: url)
        })
        .subscribe(on: Scheduler.backgroundWorkScheduler)
        .receive(on: Scheduler.mainScheduler)
        .share()
        .eraseToAnyPublisher()
    }
    
    func loadOfflineMovie(with id: Int) -> AnyPublisher<Movie?, Never> {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else { return .just(nil) }
        return Deferred { return Just(MovieDetailsHandler.fetchMovieDetail(id, moc: context)) }
        .subscribe(on: Scheduler.backgroundWorkScheduler)
        .receive(on: Scheduler.mainScheduler)
        .share()
        .eraseToAnyPublisher()
    }
    
    func loadOfflineMoviesList() -> AnyPublisher<[Movie]?, Never> {
        guard let context = AppDelegate.appDelegateInstance?.backgroundContext() else { return .just(nil) }
        return Deferred { return Just(MovieListHandler.fetchSavedNowPlayingMovieList(in: context)) }
        .subscribe(on: Scheduler.backgroundWorkScheduler)
        .receive(on: Scheduler.mainScheduler)
        .share()
        .eraseToAnyPublisher()
    }
    
    func fetchLatestMovies(with page: Int) -> AnyPublisher<Result<Movies, Error>, Never> {
        return networkService
            .load(Resource<Movies>.latestMovies(page: page))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Movies, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }

}
