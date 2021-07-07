//
//  AppDelegate.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 07/07/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    /// A Reachability instance
    let reachability = Reachability()
    /// A Boolean which identifies whether the network is reachable or not
    var isReachable = true
    /// A static AppDelegate instance which can be retrieved from anywhere of the app
    static var appDelegateInstance: AppDelegate? {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as? AppDelegate
        }
        return nil
    }
    private var initialViewController: MoviesSearchViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureReachability()
        configureWindow()
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MovieDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate {
    /// Configures the window using the mocking view controller as the root
    private func configureWindow() {
        // Initial view controller will be displayed first
        if let initViewController = UIViewController.getViewController(ofType: MoviesSearchViewController.self, fromStoryboardName: "NowPlayingMovies", storyboardId: MoviesSearchViewController.className, bundle: .main) {
            initialViewController = initViewController
        }
        configureWindow(with: initialViewController)
    }
    
    private func configureWindow(with rootVC: UIViewController?) {
        if let root = rootVC {
            let navigationController = UINavigationController(rootViewController: root)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.backgroundColor = UIColor.lightGray
            window?.makeKeyAndVisible()
        }
    }
    //MARK: Configure Reachability
    private func configureReachability() {
        // Observer network changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        // Start Reachability Notifier
        do {
        try reachability?.startNotifier()
        if let connection = reachability?.connection, connection == .none {
            isReachable = false
        } else {
            isReachable = true
        }
        } catch {
            print("couldn't start reachability notifier")
        }
    }
    
    //MARK: Reachability handler
    @objc
    func reachabilityDidChange(notification: Notification) {
        if let reachability = notification.object as? Reachability {
            switch reachability.connection {
            case .wifi:
                print("Reachable via Wifi")
                isReachable = true
            case .cellular:
                print("Reachable via Cellular")
                isReachable = true
            case .none:
                print("Network is not reachable")
                isReachable = false
            }
        }
    }
}
