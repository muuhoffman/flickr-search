//
//  ImageDetailViewController.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/24/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    var flickrPhoto: FlickrPhoto!
    var imageView: UIImageView!
    var favoriteButton: UIButton!
    struct favoriteButtonSize {
        static let width: CGFloat = 58
        static let height: CGFloat = 58
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Constants.Color.black
        
        self.imageView = ({
            let imageView = UIImageView(frame: self.view.frame)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            return imageView
        })()
        
        self.favoriteButton = ({
            // favorite view
            let buttonX = self.view.frame.width - favoriteButtonSize.width - 8
            let buttonY = self.view.frame.height - favoriteButtonSize.height - 8
            let button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: favoriteButtonSize.width, height: favoriteButtonSize.height))
            button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
            if flickrPhoto.isFavorite {
                button.setImage(#imageLiteral(resourceName: "star-full"), for: .normal)
            } else {
                button.setImage(#imageLiteral(resourceName: "star-empty"), for: .normal)
            }
            button.addTarget(self, action: #selector(favoriteDidTap(sender:)), for: .touchUpInside)
            return button
        })()
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.favoriteButton)
        
        // TODO show loader until we get the image
        self.flickrPhoto.getImage { [weak self] (image) in
            // TODO: cancel loader
            self?.imageView.image = image
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageView.frame = self.view.frame
    }
    
    func favoriteDidTap(sender: UIButton) {
        // TODO: Persist the favorite
        if self.flickrPhoto.isFavorite {
            self.flickrPhoto.isFavorite = false
            self.favoriteButton.setImage(#imageLiteral(resourceName: "star-empty"), for: .normal)
        } else {
            self.flickrPhoto.isFavorite = true
            self.favoriteButton.setImage(#imageLiteral(resourceName: "star-full"), for: .normal)
        }
    }
}
