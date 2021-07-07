//
//  UIViewController+Child.swift
//  TMDB
//
//  Created by Maksym Shcheglov on 05/10/2019.
//  Copyright © 2019 Maksym Shcheglov. All rights reserved.
//

import UIKit

extension UIViewController {
    public func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        child.didMove(toParent: self)
    }

    public func remove(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }

        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

extension UIViewController {
    /// Initialises Any type of UIViewController
    ///
    /// - Parameters:
    ///   - type: A generic instance of type UIViewController
    ///   - storyboardName: A String value which defines the storyboard name from which the UIViewController should be initialised
    ///   - storyboardId: A String value which defines an unique identifier for each UIViewController instance
    ///   - bundle: A Bundle instance
    /// - Returns: Type of UIViewController
    class func getViewController<T>(ofType type: T.Type,
                                    fromStoryboardName storyboardName: String,
                                    storyboardId: String,
                                    bundle: Bundle) -> T? where T: UIViewController {
        let designatedViewController = UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: storyboardId)
        return designatedViewController as? T
    }
}

// MARK: - General Extensions
extension NSObject {
    /// Gives the string value of any NSObject instance
    var className: String {
        return String(describing: type(of: self))
    }
    /// Gives the string value of any NSObject instance
    class var className: String {
        return String(describing: self)
    }
}
