//
//  Model.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/22/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto {
    var image: UIImage?
    var isFavorite: Bool=false
    
    var id: String
    var title: String
    var farm: String
    var server: String
    var secret: String
    
    init(id: String, title: String, farm: String, server: String, secret: String) {
        self.id = id
        self.title = title
        self.farm = farm
        self.server = server
        self.secret = secret
    }
}

class FlickrPage {
    var page: Int
    var perpage: Int
    var totalPages: Int
    var totalPhotos: Int
    var photos: [FlickrPhoto]
    
    init(page: Int, perpage: Int, totalPages: Int, totalPhotos: Int, photos: [FlickrPhoto]) {
        self.page = page
        self.perpage = perpage
        self.totalPages = totalPages
        self.totalPhotos = totalPhotos
        self.photos = photos
    }
}
