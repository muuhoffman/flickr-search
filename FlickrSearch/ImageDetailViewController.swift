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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.red
        
        self.imageView = UIImageView(frame: self.view.frame)
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(self.imageView)
        
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
}
