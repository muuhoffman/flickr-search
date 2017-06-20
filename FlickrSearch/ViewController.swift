//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/20/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Flickr Search"
        view.backgroundColor = Constants.Color.SearchViewControllerBackground
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonAction(sender: UIButton!) {
        printDeviceInfo()
    }
    
    func orientationChanged(notification: NSNotification) {
        printDeviceInfo()
    }
    
    func printDeviceInfo() {
        switch Constants.Device.idiom {
        case .phone:
            print("iphone")
        case .pad:
            print("ipad")
        default:
            print("other idiom")
        }
        
        switch Constants.Device.orientation {
        case .landscapeLeft, .landscapeRight:
            print("landscape")
        case .portrait, .portraitUpsideDown:
            print("portrait")
        default:
            print("unknown")
        }
        
        print("Height", Constants.Device.screenHeight)
        print("Width", Constants.Device.screenWidth)
    }

}

