//
//  ImageSize.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation

enum ImageSize {
    case small
    case original
    var url: URL {
        switch self {
        case .small: return ApiConstants.smallImageUrl
        case .original: return ApiConstants.originalImageUrl
        }
    }
}
