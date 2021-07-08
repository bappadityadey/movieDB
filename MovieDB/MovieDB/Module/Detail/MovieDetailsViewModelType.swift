//
//  MovieDetailsViewModelType.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import UIKit
import Combine

// INPUT
struct MovieDetailsViewModelInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
}

// OUTPUT
enum MovieDetailsState {
    case loading
    case success(MovieViewModel)
    case failure(Error)
}

extension MovieDetailsState: Equatable {
    static func == (lhs: MovieDetailsState, rhs: MovieDetailsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success(let lhsMovie), .success(let rhsMovie)): return lhsMovie == rhsMovie
        case (.failure, .failure): return true
        default: return false
        }
    }
}

typealias MovieDetailsViewModelOutput = AnyPublisher<MovieDetailsState, Never>

protocol MovieDetailsViewModelType: AnyObject {
    func transform(input: MovieDetailsViewModelInput) -> MovieDetailsViewModelOutput
    func addToFavourite()
    func removeFromFavourite()
    func isMovieExistsInFavourites() -> Bool
}
