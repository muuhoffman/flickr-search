//
//  NetworkService.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/22/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import Foundation

class NetworkService {
    
    typealias QueryResult = (FlickrPage?, String) -> ()
    typealias JSONDictionary = [String: Any]

    static let shared = NetworkService()
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func getSearchResults(searchText: String, page: Int, completion: @escaping QueryResult) {
        dataTask?.cancel()
        if let url = generateFlickrSearchUrl(searchText: searchText, page: page) {
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    DispatchQueue.main.async {
                        completion(nil, "DataTask error: " + error.localizedDescription + "\n")
                    }
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    let result = self.parseSearchResults(data: data)
                    DispatchQueue.main.async {
                        completion(result.page, result.errorMessage)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    private func generateFlickrSearchUrl(searchText: String, page: Int) -> URL? {
        // https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=57c38f7fc38163aac918172b8928af95&text=cat+dog&per_page=20&page=1&format=json&nojsoncallback=1&api_sig=6ea7d34bb8b4e0268f6cdb95a342ae7a
        
        if var urlComponents = URLComponents(string: "https://api.flickr.com/services/rest") {
            urlComponents.query = "method=flickr.photos.search&api_key=\(Constants.Flickr.apiKey)&text=\(searchText)&per_page=\(Constants.Flickr.resultsPerPage)&page=\(page)&format=json&nojsoncallback=1"
            return urlComponents.url
        }
        return nil
    }
    
    private func parseSearchResults(data: Data) -> (page: FlickrPage?, errorMessage: String) {
        var response: JSONDictionary?
        var result: [FlickrPhoto] = [FlickrPhoto]()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            let errorMessage = "JSONSerialization error: \(parseError.localizedDescription)\n"
            return (nil, errorMessage)
        }
        
        guard let photos = response!["photos"] as? JSONDictionary else {
            let errorMessage = "Dictionary does not contain 'photos' key"
            return (nil, errorMessage)
        }
        
        guard let page = photos["page"] as? Int else {
            let errorMessage = "Dictionary does not contain 'page' key"
            return (nil, errorMessage)
        }
        
        guard let perpage = photos["perpage"] as? Int else {
            let errorMessage = "Dictionary does not contain 'perpage' key"
            return (nil, errorMessage)
        }
        
        guard let totalPages = photos["pages"] as? Int else {
            let errorMessage = "Dictionary does not contain 'pages' key"
            return (nil, errorMessage)
        }
        
        guard let totalPhotosString = photos["total"] as? String, let totalPhotos = Int(totalPhotosString) else {
            let errorMessage = "Dictionary does not contain 'total' key"
            return (nil, errorMessage)
        }
        
        guard let photoArray = photos["photo"] as? [JSONDictionary] else {
            let errorMessage = "Dictionary does not contain 'photo' key"
            return (nil, errorMessage)
        }
        
        for (index, photo) in photoArray.enumerated() {
            if let id = photo["id"] as? String,
                let title = photo["title"] as? String,
                let farmInt = photo["farm"] as? Int,
                let server = photo["server"] as? String,
                let secret = photo["secret"] as? String
            {
                result.append(FlickrPhoto(id: id, title: title, farm: String(farmInt), server: server, secret: secret))
            } else {
                let errorMessage = "Dictionary has invalid 'photo' object at index \(index)"
                return (nil, errorMessage)
            }
        }
        return (FlickrPage(page: page, perpage: perpage, totalPages: totalPages, totalPhotos: totalPhotos, photos: result), "")
    }
}
