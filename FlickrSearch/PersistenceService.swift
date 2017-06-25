//
//  PersistenceService.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/24/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import Foundation

class PersistenceService {
    typealias QueryResult = (FlickrPage?, String) -> ()
    typealias FlickrImageId = String
    
    struct UserDefaultsKeys {
        static let favorites = "favorites"
    }
    
    static let shared = PersistenceService()
    
    var favorites: Set<FlickrImageId> = Set()

    func getSearchResults(searchText: String, page: Int, completion: @escaping QueryResult) {
        NetworkService.shared.getSearchResults(searchText: searchText, page: page) { (page, errorMessage) in
            if let page = page {
                // set favorites
                page.photos.forEach({ (photo) in
                    photo.isFavorite = self.favorites.contains(photo.id)
                })
                completion(page, errorMessage)
            } else {
                completion(nil, errorMessage)
            }
        }
    }
    
    func setFavorite(imageId: FlickrImageId, isFavorite: Bool) {
        if isFavorite {
            favorites.insert(imageId)
        } else {
            favorites.remove(imageId)

        }
    }
    
    func saveFavorites() {
        UserDefaults.standard.setValue(Array(self.favorites), forKey: UserDefaultsKeys.favorites)
        UserDefaults.standard.synchronize()
    }
    
    func readFavorites() {
        self.favorites = Set(UserDefaults.standard.object(forKey: UserDefaultsKeys.favorites) as? [FlickrImageId] ?? [])
    }
    
}
