//
//  Movies.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation

struct Movies {
    let items: [Movie]
    let totalPages: Int
    let totalResults: Int
}

extension Movies: Decodable {

    enum CodingKeys: String, CodingKey {
        case items = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie {
    let id: Int
    let title: String
    let overview: String
    let poster: String?
    let voteAverage: Float
    let releaseDate: String?
    let backdropPath: String?
    let originalLanguage: String?
    let originalTitle: String?
    let popularity: Float
    let video: Bool
    let adult: Bool
    let voteCount: Int
    let genreIds: [GenreId]?
    let genres: [Genre]?
}

extension Movie: Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Movie: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case video
        case popularity
        case adult
        case poster = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case genres = "genres"
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case voteCount = "vote_count"
    }
}
