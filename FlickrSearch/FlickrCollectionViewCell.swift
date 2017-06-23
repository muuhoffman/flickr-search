//
//  FlickrCollectionViewCell.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/21/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell: UICollectionViewCell {
    var flickrPhoto: FlickrPhoto? {
        didSet {
            print(flickrPhoto?.title)
        }
    }
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init called", "frame:", frame)
        self.imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView?.clipsToBounds = true
        self.addSubview(self.imageView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.imageView?.frame = CGRect(x: 0.0, y: 0.0, width: layoutAttributes.frame.width, height: layoutAttributes.frame.height)
    }
    
    func setNewContent(content: FlickrPhoto) {
        self.imageView?.image = nil
        // pause previous content's download
        self.flickrPhoto?.pauseDownload()
        // set the new content
        self.flickrPhoto = content
        // get the new image
        self.flickrPhoto?.getImage(completion: { (image) in
            self.imageView?.image = image  // TODO: Do we need a weak reference here?
        })
    }
}
