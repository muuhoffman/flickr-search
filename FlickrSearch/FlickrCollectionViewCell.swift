//
//  FlickrCollectionViewCell.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/21/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell: UICollectionViewCell {
    var flickrPhoto: FlickrPhoto?
    var imageView: UIImageView!
    var favoriteButton: UIButton!
    var acitivityIndicator: CircleActivityIndicator!
    
    struct favoriteButtonSize {
        static let width: CGFloat = 44
        static let height: CGFloat = 44
    }
    
    struct ActivityIndicatorSize {
        static let width: CGFloat = 50
        static let height: CGFloat = 50
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // image view
        self.imageView = ({
            let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        })()
        
        self.favoriteButton = ({
            // favorite view
            let buttonX = self.frame.width - favoriteButtonSize.width - 4
            let buttonY = self.frame.height - favoriteButtonSize.height - 4
            let button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: favoriteButtonSize.width, height: favoriteButtonSize.height))
            button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
            button.addTarget(self, action: #selector(favoriteDidTap(sender:)), for: .touchUpInside)
            return button
        })()
        
        self.acitivityIndicator = ({
            let activityIndicatorOriginX = self.frame.width/2.0 - ActivityIndicatorSize.width/2.0
            let activityIndicatorOriginY = self.frame.height/2.0 - ActivityIndicatorSize.height/2.0
            let activityIndicator = CircleActivityIndicator(frame: CGRect(x: activityIndicatorOriginX , y: activityIndicatorOriginY, width: ActivityIndicatorSize.width, height: ActivityIndicatorSize.height))
            activityIndicator.color = UIColor.white
            return activityIndicator
        })()
        
        self.addSubview(self.imageView!)
        self.addSubview(self.favoriteButton!)
        self.addSubview(self.acitivityIndicator!)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.imageView.frame = CGRect(x: 0.0, y: 0.0, width: layoutAttributes.frame.width, height: layoutAttributes.frame.height)
        self.favoriteButton.frame = CGRect(x: layoutAttributes.frame.width - favoriteButtonSize.width - 4, y: layoutAttributes.frame.height - favoriteButtonSize.height - 4, width: favoriteButtonSize.width, height: favoriteButtonSize.height)
        let activityIndicatorOriginX = layoutAttributes.frame.width/2.0 - ActivityIndicatorSize.width/2.0
        let activityIndicatorOriginY = layoutAttributes.frame.height/2.0 - ActivityIndicatorSize.height/2.0
        self.acitivityIndicator.frame = CGRect(x: activityIndicatorOriginX , y: activityIndicatorOriginY, width: ActivityIndicatorSize.width, height: ActivityIndicatorSize.height)
    }
    
    func setNewContent(content: FlickrPhoto) {
        self.imageView.image = nil
        // pause previous content's download
        self.flickrPhoto?.pauseDownload()
        // set the new content
        self.flickrPhoto = content
        
        // start the activity indicator
        self.acitivityIndicator.startAnimating()
        
        // get the new image
        self.flickrPhoto?.getImage(completion: { [weak self] (image) in
            self?.acitivityIndicator.stopAnimating()
            self?.imageView.image = image
            self?.setFavorite(isFavorite: self?.flickrPhoto?.isFavorite ?? false)
        })
    }
    
    func favoriteDidTap(sender: UIButton) {
        guard let isFavorite = self.flickrPhoto?.isFavorite, let imageId = self.flickrPhoto?.id else {
            return
        }
        setFavorite(isFavorite: !isFavorite)
        PersistenceService.shared.setFavorite(imageId: imageId, isFavorite: !isFavorite)
    }
    
    private func setFavorite(isFavorite: Bool) {
        self.flickrPhoto?.isFavorite = isFavorite
        self.favoriteButton.setImage(isFavorite ? #imageLiteral(resourceName: "star-full") : #imageLiteral(resourceName: "star-empty"), for: .normal)
    }
}
