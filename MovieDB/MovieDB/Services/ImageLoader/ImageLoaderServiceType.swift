//
//  ImageLoaderServiceType.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import Foundation
import UIKit.UIImage
import Combine

protocol ImageLoaderServiceType: AnyObject, AutoMockable {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}
