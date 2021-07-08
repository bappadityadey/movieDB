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

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let voteAverage: Float?
    let releaseDate: String?
    let backdropPath: String?
    let originalLanguage: String?
    let originalTitle: String?
    let popularity: Float?
    let video: Bool?
    let adult: Bool?
    let voteCount: Int?
    let genre_ids: [GenreId]?
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

extension Movie {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case video
        case popularity
        case adult
        case poster_path
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genre_ids
        case genres
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case voteCount = "vote_count"
    }
}
