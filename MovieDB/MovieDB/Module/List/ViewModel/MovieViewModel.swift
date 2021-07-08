//
//  MovieViewModel.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation
import UIKit.UIImage
import Combine

struct MovieViewModel {
    let id: Int
    let title: String
    let subtitle: String
    let overview: String
    let poster: AnyPublisher<UIImage?, Never>
    let rating: String

    init(id: Int, title: String, subtitle: String, overview: String, poster: AnyPublisher<UIImage?, Never>, rating: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.overview = overview
        self.poster = poster
        self.rating = rating
    }
}

extension MovieViewModel: Hashable {
    static func == (lhs: MovieViewModel, rhs: MovieViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

