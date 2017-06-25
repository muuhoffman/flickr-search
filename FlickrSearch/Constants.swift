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
        static let pink = UIColor(red: 250, green: 0, blue: 124, alpha: 1)
        static let blue = UIColor(rgb: 0x0061D4)
        static let black = UIColor(red: 32, green: 32, blue: 35, alpha: 1)
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
