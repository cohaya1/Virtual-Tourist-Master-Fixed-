//
//  FlickrNetwork.swift
//  Virtual Tourist
//
//  Created by Makaveli Ohaya on 4/19/20.
//  Copyright © 2020 Ohaya. All rights reserved.
//

import Foundation
import UIKit

class FlickrNetwork {
    
    
    enum Endpoints {
        static let flickrAPIKey = "218f72f08c12cf12e43764e9dd1aaf79"
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let SearchUrlMethod = "flickr.photos.search"
        static let numberOfPhotos = 20
        case searchURL(Double, Double, Int, Int)
        
        var url: URL {
            return URL(string: urlString)!
        }
        
        var urlString: String {
            switch self {
            case .searchURL(let lat, let lon, let perPage, let pageNum):
                return Endpoints.baseURL + "&api_key=\(Endpoints.flickrAPIKey)" + "&lat=\(lat)" + "&lon=\(lon)" + "&radius=\(Endpoints.numberOfPhotos)" + "&per_page=\(perPage)" + "&page=\(pageNum)" + "&format=json&nojsoncallback=1&extras=url_m"
            }
        }
    }
    
    class func randomPageNumber(totalPictures: Int, picturesShown: Int) -> Int {
        let flickrLimit = 4000
        let numberOfPages = min(totalPictures, flickrLimit) / picturesShown
        let randomPageNumber = Int.random(in: 0...numberOfPages)
        return randomPageNumber
    }
    
    class func getFlickrURL(latitude: Double, longitude: Double, totalPages: Int = 0, picturesPerPage: Int = 15) -> URL {
        let perPage = picturesPerPage
        let pageNum = randomPageNumber(totalPictures: totalPages, picturesShown: picturesPerPage)
        let searchURL = Endpoints.searchURL(latitude, longitude, perPage, pageNum).url
        return searchURL
    }
    
    class func searchPhotos(latitude: Double, longitude: Double, totalPages: Int = 0, completion: @escaping ([UIImage], Error?) -> Void) {
        let url = getFlickrURL(latitude: latitude, longitude: longitude, totalPages: totalPages)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion([], error)
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let data = data else {
                completion([], error)
                return
            }
            
            var parsedData: [String:AnyObject]!
            
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] //parse data
                print(parsedData ?? "Parsed Data nil")
            } catch let error {
                print(error.localizedDescription)
            }
            
            guard let photosDict = parsedData[FlickrJSON.photos] as? [String:AnyObject] else {
                fatalError("\(FlickrJSON.photos) is nil")
            }

            guard let photosArr = photosDict[FlickrJSON.photo] as? [[String: AnyObject]] else {
                fatalError("\(FlickrJSON.photo) is nil")
            }
    
            
            if photosArr.count == 0 {
                fatalError("No photos")
            } else {
                var imageArray: [UIImage] = []
                for _ in 1...21{
                    let randomPhotoNum = Int(arc4random_uniform(UInt32(photosArr.count)))
                    let photoDict = photosArr[randomPhotoNum] as [String: AnyObject]
                    guard let imageURLString = photoDict[FlickrJSON.mediumURL] as? String else {
                        return
                    }
                    
                    let imageURL = URL(string: imageURLString)
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        imageArray.append(UIImage(data: imageData)!)
                    } else {
                        print("Image not found: \(String(describing: imageURL))")
                    }

                }
                completion(imageArray, nil)
            }
        }
        task.resume()
    }
}
