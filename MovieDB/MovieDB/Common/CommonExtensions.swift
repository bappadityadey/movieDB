//
//  CommonExtensions.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 08/07/21.
//

import Foundation
import UIKit

extension Array where Element: Hashable {
    func uniqueElements() -> [Element] {
        var seen = Set<Element>()
        var out = [Element]()

        for element in self {
            if !seen.contains(element) {
                out.append(element)
                seen.insert(element)
            }
        }
        return out
    }
}

extension FileManager {
    func documentDirectoryPath() throws -> String? {
        var docDir: String?
        do {
        let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            docDir = documentsURL.path
        } catch {
            print("could not get docDirPath due to FileManager error: \(error)")
        }
        return docDir
    }
}

protocol NibProvidable {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibProvidable {
    static var nibName: String {
        return "\(self)"
    }
    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

// Cell
extension UITableView {
    func registerClass<T: UITableViewCell>(cellClass `class`: T.Type) where T: ReusableView {
        register(`class`, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func registerNib<T: UITableViewCell>(cellClass `class`: T.Type) where T: NibProvidable & ReusableView {
        register(`class`.nib, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type) -> T? where T: ReusableView {
        return self.dequeueReusableCell(withIdentifier: `class`.reuseIdentifier) as? T
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type, forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: `class`.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Error: cell with identifier: \(`class`.reuseIdentifier) for index path: \(indexPath) is not \(T.self)")
        }
        return cell
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
