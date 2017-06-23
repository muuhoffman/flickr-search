//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/20/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate let navBarTitle = "Flickr Search"
    
    fileprivate struct ReuseIdentifier {
        static let flickrCell = "FlickrCell"
    }
    fileprivate let sectionInsets = UIEdgeInsets(top: 35.0, left: 10.0, bottom: 35.0, right: 10.0)
    fileprivate var itemsPerRow: Int {  // TODO: For performance, may want to only set this on orientation changes rather than having it be a computed property
        switch Constants.Device.idiom {
        case .phone:
            return Constants.Device.orientation.isLandscape ? 2 : 1
        case .pad:
            return 2
        default:
            return 1
        }
    }// = Constants.Device.idiom == UIUserInterfaceIdiom.phone ? 1 : 2
    
    var collectionView: UICollectionView!
    var searchBar:UISearchBar!
    var searchButton: UIBarButtonItem!
    var cancelSearchButton: UIBarButtonItem!
    
    var debouncedSearch: (()->())!
    
    var searchResults: [FlickrPhoto] = [FlickrPhoto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = navBarTitle
        self.view.backgroundColor = Constants.Color.SearchViewControllerBackground
        
        self.collectionView = ({
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = sectionInsets
            layout.itemSize = CGSize(width: 100, height: 100)
            
            let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            collectionView.dataSource = self
            collectionView.delegate = self
            
            collectionView.register(FlickrCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier.flickrCell)
            
            return collectionView
        })()
        
        self.view.addSubview(self.collectionView)
        
        // search button
        searchButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchButtonDidTap(sender:)))
        self.navigationItem.rightBarButtonItem = searchButton
        
        // cancel search button
        cancelSearchButton = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelSearchButtonDidTap(sender:)))
        
        // search bar
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))  // TODO:
        searchBar.placeholder = "Search Flickr"
        searchBar.delegate = self
        
        debouncedSearch = debounce(delay: 1000, queue: DispatchQueue.main, action: {
            // This is a new search
            // Clear old search
            self.searchResults.removeAll()
            self.collectionView.reloadData()
            // If no search text, don't search, just clear the data
            guard let searchText = self.searchBar.text, searchText != "" else {
                return
            }
            // Start new search request
            NetworkService.shared.getSearchResults(searchText: searchText, page: 1, completion: { [weak self] (page, errorMessage) in
                if let page = page {
                    self?.searchResults.append(contentsOf: page.photos)
                    self?.collectionView.reloadData()
                } else {
                    print(errorMessage)
                }
            })
        })
        
//        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//        button.backgroundColor = .green
//        button.setTitle("Test Button", for: .normal)
//        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        
//        self.view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizeSearchBar()
        self.collectionView.frame = self.view.frame
        self.collectionView.collectionViewLayout.invalidateLayout()
        // self.collectionView.reloadData()  // TODO: Enable if image cells don't reload properly
    }
    
    func resizeSearchBar() {
        let buttonItemView = cancelSearchButton.value(forKey: "view") as? UIView
        let buttonItemSize = buttonItemView?.frame.width ?? 100.0
        let searchBarWidth = self.view.frame.width - buttonItemSize - 50.0
        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: searchBarWidth, height: searchBar.frame.height)
    }

    func searchButtonDidTap(sender: UIBarButtonItem!) {
        self.title = nil
        self.navigationItem.rightBarButtonItem = cancelSearchButton
        resizeSearchBar()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    func cancelSearchButtonDidTap(sender: UIBarButtonItem!) {
        self.navigationItem.leftBarButtonItem = nil
        self.title = navBarTitle
        self.navigationItem.rightBarButtonItem = searchButton
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

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.flickrCell,
                                                      for: indexPath) as! FlickrCollectionViewCell
        
//        switch indexPath.row % itemsPerRow {
//        case 0:
//            cell.backgroundColor = UIColor.blue
//        default:
//            cell.backgroundColor = UIColor.red
//        }
        cell.backgroundColor = UIColor.clear
        cell.setNewContent(content: self.searchResults[indexPath.row])
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let itemsPerRowCGFloat = CGFloat.init(itemsPerRow)
        let horizontalPaddingSpace = sectionInsets.left * (itemsPerRowCGFloat + 1)
        let availableWidth = view.frame.width - horizontalPaddingSpace
        let verticalPaddingSpace = sectionInsets.top * (itemsPerRowCGFloat + 1)
        let availableHeight = view.frame.height - verticalPaddingSpace
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        if itemsPerRow == 1 {
            let dimension = availableWidth < availableHeight ? availableWidth : availableHeight
            width = dimension
            height = dimension
        } else if itemsPerRow == 2 {
            let wideWidthPercent: CGFloat = 0.60
            let regularWidthPercent: CGFloat = 1.0 - wideWidthPercent
            var regularWidth = availableWidth * regularWidthPercent
            let isHeightSmaller = availableHeight < regularWidth
            height = isHeightSmaller ? availableHeight : regularWidth
            regularWidth = height
            
            switch indexPath.row % 4 {
            case 0, 3:
                width = regularWidth
            case 1, 2:
                if isHeightSmaller {
                    let widthRatio = wideWidthPercent / regularWidthPercent
                    let wideWidth = regularWidth * widthRatio
                    width = wideWidth
                } else {
                    width = availableWidth - regularWidth
                }
            default:
                assertionFailure("Index Path % 4 should never equal anything other than 0,1,2,3")
            }
        } else {
            assertionFailure("Items per row can only be 1 or 2, if you want a different layout, it needs to be implemented!")
        }
        return CGSize(width: width, height: height)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncedSearch()
    }
    
    func debounce(delay:Int, queue:DispatchQueue, action: @escaping (()->())) -> ()->() {
        var lastFireTime = DispatchTime.now()
        let dispatchDelay = DispatchTimeInterval.milliseconds(delay)
        
        return {
            lastFireTime = DispatchTime.now()
            let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
            queue.asyncAfter(deadline: dispatchTime, execute: {
                let when: DispatchTime = lastFireTime + dispatchDelay
                let now = DispatchTime.now()
                if now.rawValue >= when.rawValue {
                    action()
                }
            })
        }
    }
}
