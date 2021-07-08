//
//  MovieDetailsHandler.swift
//  MovieDB
//
//  Created by Bappaditya Dey on 08/07/21.
//

import Foundation
import CoreData

class MovieDetailsHandler {
    
    static func removeMovieInfoObjectFromSavedItems(_ movieId: Int, moc: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteMovieMO")
        fetchRequest.predicate = NSPredicate(format: "id == \(movieId)")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try moc.execute(batchDeleteRequest)
        } catch {
            print("Could not delete SavedItemsMO entity record for id: \(movieId) \(error)")
        }
    }
    
    static func addMovieInfoObjectToSavedItems(_ movieId: Int, moc: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieMO")
        let predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = predicate
        do {
            if let movieMO = try moc.fetch(fetchRequest).first as? MovieMO {
                if let entity = NSEntityDescription.entity(forEntityName: "FavouriteMovieMO", in: moc) {
                    let savedItemsMO = NSManagedObject(entity: entity, insertInto: moc)
                    savedItemsMO.setValue(movieMO.id, forKeyPath: "id")
                    savedItemsMO.setValue(movieMO.title, forKey: "title")
                    savedItemsMO.setValue(movieMO.subtitle, forKey: "subtitle")
                    savedItemsMO.setValue(movieMO.overview, forKey: "overview")
                    savedItemsMO.setValue(movieMO.poster_path, forKey: "poster_path")
                    savedItemsMO.setValue(movieMO.genre_ids, forKey: "genre_ids")
                    savedItemsMO.setValue(movieMO.index, forKey: "index")
                    savedItemsMO.setValue(movieMO.vote_average, forKey: "vote_average")
                    savedItemsMO.setValue(movieMO.release_date, forKey: "release_date")
                }
            }
            try moc.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func fetchMovieDetail(_ movieId: Int, moc: NSManagedObjectContext) -> Movie? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieMO")
        let predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = predicate
        var movieListVO: [Movie]?
        do {
            let movieMO = try moc.fetch(fetchRequest)
            if movieMO.count > 0 {
                let json = JSONConverter.convertToJSONArray(moArray: movieMO)

                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
                    do {
                        movieListVO = try JSONDecoder().decode([Movie].self, from: jsonData)
                        return movieListVO?.first
                    } catch {
                        print("error occurred while creating movie VO = \(error), json = \(json)")
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    static func isMovieExistsInFavourites(_ movieId: Int, moc: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteMovieMO")
        let predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = predicate
        do {
            let movieMO = try moc.fetch(fetchRequest)
            return !movieMO.isEmpty
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
}
