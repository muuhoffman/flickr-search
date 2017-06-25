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
    var activityIndicator: CircleActivityIndicator!
    
    struct FavoriteButtonSize {
        static let width: CGFloat = 58
        static let height: CGFloat = 58
    }
    
    struct ActivityIndicatorSize {
        static let width: CGFloat = 50
        static let height: CGFloat = 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Constants.Color.black
        self.title = flickrPhoto.title
        
        self.imageView = ({
            let imageView = UIImageView(frame: self.view.frame)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            return imageView
        })()
        
        self.favoriteButton = ({
            // favorite view
            let buttonX = self.view.frame.width - FavoriteButtonSize.width - 8
            let buttonY = self.view.frame.height - FavoriteButtonSize.height - 8
            let button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: FavoriteButtonSize.width, height: FavoriteButtonSize.height))
            button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
            button.addTarget(self, action: #selector(favoriteDidTap(sender:)), for: .touchUpInside)
            return button
        })()
        
        // activityIndicator
        self.activityIndicator = ({
            let activityIndicator = CircleActivityIndicator(frame: CGRect(x: self.view.frame.midX - ActivityIndicatorSize.width/2.0, y: self.view.frame.midY - ActivityIndicatorSize.height/2.0, width: ActivityIndicatorSize.width, height: ActivityIndicatorSize.height))
            activityIndicator.color = Constants.Color.blue
            return activityIndicator
        })()
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.favoriteButton)
        self.view.addSubview(activityIndicator)
        
        // TODO show loader until we get the image
        self.activityIndicator.startAnimating()
        self.flickrPhoto.getImage { [weak self] (image) in
            self?.activityIndicator.stopAnimating()
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
