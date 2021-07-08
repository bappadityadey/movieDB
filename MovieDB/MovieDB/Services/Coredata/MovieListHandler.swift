//
//  MovieListHandler.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 08/07/21.
//

import Foundation
import CoreData

class MovieListHandler {
    typealias JSON = [String: Any]

    static func clearNowPlayingMO(moc: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NowPlayingMO")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moc.execute(batchDeleteRequest)
        } catch {
            print("Could not delete NowPlayingMO entity records. \(error)")
        }
    }
    
    static func saveCurrentMovieList(_ movieInfoList: [Movie], moc: NSManagedObjectContext) {
        moc.performAndWait {
            for (index, movie) in movieInfoList.enumerated() {
                if let entity = NSEntityDescription.entity(forEntityName: "MovieMO", in: moc) {
                    let nowPlayingMO = NSManagedObject(entity: entity, insertInto: moc)
                    nowPlayingMO.setValue(movie.id, forKeyPath: "id")
                    nowPlayingMO.setValue(movie.title, forKey: "title")
                    nowPlayingMO.setValue(movie.subtitle, forKey: "subtitle")
                    nowPlayingMO.setValue(movie.overview, forKey: "overview")
                    nowPlayingMO.setValue(movie.poster_path, forKey: "poster_path")
                    nowPlayingMO.setValue(movie.genre_ids.map{ $0.map{ $0.rawValue }}, forKey: "genre_ids")
                    nowPlayingMO.setValue(index, forKey: "index")
                    nowPlayingMO.setValue(String(format: "%.2f", movie.voteAverage ?? 0.0), forKey: "rating")
                }
            }
        }
        
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func fetchSavedNowPlayingMovieList(in moc: NSManagedObjectContext) -> [Movie] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieMO")
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        var movieListVO: [Movie]?
        do {
            let nowPlayingMO = try moc.fetch(fetchRequest)
            if nowPlayingMO.count > 0 {
                let json = Self.convertToJSONArray(moArray: nowPlayingMO)

                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
                    do {
                        movieListVO = try JSONDecoder().decode([Movie].self, from: jsonData)
                    } catch {
                        print("error occurred while creating drawing pin VO = \(error), json = \(json)")
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return movieListVO ?? []
    }
    
    static func convertToJSONArray(moArray: [NSManagedObject]) -> [JSON] {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
}
