//
//  Constants.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/20/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Color {
        static let SearchViewControllerBackground = UIColor.yellow
    }
    
    struct Device {
        static var idiom: UIUserInterfaceIdiom {
            get {
                return UIDevice.current.userInterfaceIdiom
            }
        }
        static var orientation: UIInterfaceOrientation {
            get {
                return UIApplication.shared.statusBarOrientation
            }
        }

        static var screenSize: CGRect {
            get {
                return UIScreen.main.bounds
            }
        }
        static var screenWidth: CGFloat {
            get {
                return screenSize.width
            }
        }
        static var screenHeight: CGFloat {
            get {
                return screenSize.height
            }
        }
    }
    
    struct Flickr {
        static var apiKey = ""
        static var apiSecret = ""
        static let resultsPerPage = 20
    }
}
