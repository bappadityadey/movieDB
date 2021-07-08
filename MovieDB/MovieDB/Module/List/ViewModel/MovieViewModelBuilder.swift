//
//  MovieViewModelBuilder.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation
import UIKit.UIImage
import Combine

struct MovieViewModelBuilder {
    static func viewModel(from movie: Movie, imageLoader: (Movie) -> AnyPublisher<UIImage?, Never>) -> MovieViewModel {
        return MovieViewModel(id: movie.id,
                              title: movie.title,
                              subtitle: movie.subtitle,
                              overview: movie.overview,
                              poster: imageLoader(movie),
                              rating: String(format: "%.2f", movie.vote_average ?? 0.0))
    }
}

extension Movie {
    var genreNames: [String] {
        if let genreIds = genre_ids {
            return genreIds.map { $0.description }
        }
        if let genres = genres {
            return genres.map { $0.name }
        }
        return []
    }
    var subtitle: String {
        let genresDescription = genreNames.joined(separator: ", ")
        return "\(releaseDate) | \(genresDescription)"
    }
    var releaseDate: String {
        return release_date ?? "2021"
    }
}
