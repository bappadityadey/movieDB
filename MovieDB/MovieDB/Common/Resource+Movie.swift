//
//  Resource+Movie.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation

extension Resource {

    static func movies(query: String) -> Resource<Movies> {
        let url = ApiConstants.baseUrl.appendingPathComponent("/search/movie")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": ApiConstants.apiKey,
            "query": query,
            "language": Locale.preferredLanguages[0]
            ]
        return Resource<Movies>(url: url, parameters: parameters)
    }

    static func details(movieId: Int) -> Resource<Movie> {
        let url = ApiConstants.baseUrl.appendingPathComponent("/movie/\(movieId)")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": ApiConstants.apiKey,
            "language": Locale.preferredLanguages[0]
            ]
        return Resource<Movie>(url: url, parameters: parameters)
    }
    
    static func latestMovies(page: Int) -> Resource<Movies> {
        let url = ApiConstants.baseUrl.appendingPathComponent("/movie/now_playing")
        let parameters: [String : CustomStringConvertible] = [
            "api_key": ApiConstants.apiKey,
            "page": page,
            "language": "en-US"
            ]
        return Resource<Movies>(url: url, parameters: parameters)
    }
}

