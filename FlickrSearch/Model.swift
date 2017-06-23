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
    var isFavorite: Bool=false
    
    var id: String
    var title: String
    private var farm: String
    private var server: String
    private var secret: String
    
    private var image: UIImage?
    private var download: URLSessionDataTask?
    private var imageCompletion: ((UIImage?) -> ())?
    
    init(id: String, title: String, farm: String, server: String, secret: String) {
        self.id = id
        self.title = title
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    // TODO: For closure, do we need weak references?
    func getImage(completion: @escaping (UIImage?)->()) {
        if let _ = image {
            completion(image!)
        } else {
            self.imageCompletion = completion
            downloadImage()
        }
    }
    
    // TODO: For closure, do we need weak references?
    private func downloadImage() {
        print("Download Started")
        let url = URL.init(string: "https://farm\(self.farm).staticflickr.com/\(self.server)/\(self.id)_\(self.secret).jpg")!
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            self.image = UIImage(data: data)
            DispatchQueue.main.async() { () -> Void in
                self.imageCompletion?(self.image)
            }
        }
    }
    
    // TODO: For closure, do we need weak references?
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        self.download = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }
        self.download?.resume()
    }
    
    func cancelDownload() {
        self.imageCompletion = nil
        self.download?.cancel()
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
