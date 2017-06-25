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
        setFavorite(isFavorite: flickrPhoto.isFavorite)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageView.frame = self.view.frame
    }
    
    func favoriteDidTap(sender: UIButton) {
        let isNowFavorite = !self.flickrPhoto.isFavorite
        setFavorite(isFavorite: isNowFavorite)
        PersistenceService.shared.setFavorite(imageId: self.flickrPhoto.id, isFavorite: isNowFavorite)
    }
    
    private func setFavorite(isFavorite: Bool) {
        self.flickrPhoto.isFavorite = isFavorite
        self.favoriteButton?.setImage(isFavorite ? #imageLiteral(resourceName: "star-full") : #imageLiteral(resourceName: "star-empty"), for: .normal)
    }
}
