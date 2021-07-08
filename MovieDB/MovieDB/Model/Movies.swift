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
    let poster_path: String?
    let vote_average: Float?
    let release_date: String?
    let backdrop_path: String?
    let original_language: String?
    let original_title: String?
    let popularity: Float?
    let video: Bool?
    let adult: Bool?
    let vote_count: Int?
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

extension Movie: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case video
        case popularity
        case adult
        case poster_path
        case vote_average
        case release_date
        case genre_ids
        case genres
        case backdrop_path
        case original_language
        case original_title
        case vote_count
    }
}
