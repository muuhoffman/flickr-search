//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/20/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class FlickrSearchViewController: UIViewController {
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
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var searchBar:UISearchBar!
    fileprivate var searchButton: UIBarButtonItem!
    fileprivate var cancelSearchButton: UIBarButtonItem!
    
    fileprivate var debouncedSearch: (()->())!
    fileprivate var searchResults: [FlickrPhoto] = [FlickrPhoto]()
    
    fileprivate var lastPageLoaded: Int = 0
    fileprivate var firstPageLoaded: Int = 0
    fileprivate var pagePointer: Int = 0
    fileprivate var picturePointer: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = navBarTitle
        self.view.backgroundColor = UIColor.white
        
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
            self.firstPageLoaded = 0
            self.lastPageLoaded = 0
            self.pagePointer = 0
            self.search(searchText: searchText, newPageNumber: 1)
        })
        
//        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//        button.backgroundColor = .green
//        button.setTitle("Test Button", for: .normal)
//        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        
//        self.view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload b/c images could be favorited in the image detail view
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        removePicturesOnMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizeSearchBar()
        self.collectionView.frame = self.view.frame
//        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.performBatchUpdates(nil, completion: nil)
        self.collectionView.reloadData()  // TODO: Enable if image cells don't reload properly
    }
    
    fileprivate func resizeSearchBar() {
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
    
    fileprivate func printDeviceInfo() {
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
    
    fileprivate func printPaginationStats() {
        let calculatedSearchResultsCount = (lastPageLoaded-firstPageLoaded+1)*Constants.Flickr.resultsPerPage
        print("firstPage: \(firstPageLoaded)\nlastPage: \(lastPageLoaded)\nsearchResultsCount: \(searchResults.count)\nexpectedSearchResultsCount: \(calculatedSearchResultsCount)")
    }
    
    fileprivate func search(searchText: String, newPageNumber: Int) {
        NetworkService.shared.getSearchResults(searchText: searchText, page: newPageNumber, completion: { [weak self] (page, errorMessage) in
            if let page = page {
                if let lastPageLoaded = self?.lastPageLoaded, newPageNumber > lastPageLoaded {
                    if self?.firstPageLoaded == 0 {
                        self?.firstPageLoaded = 1
                    }
                    self?.lastPageLoaded = newPageNumber
                    self?.searchResults.append(contentsOf: page.photos)
                    
                } else if let firstPageLoaded = self?.firstPageLoaded, newPageNumber < firstPageLoaded {
                    self?.firstPageLoaded = newPageNumber
                    self?.searchResults.insert(contentsOf: page.photos, at: 0)
                } else { // don't know where this page should go
                    assertionFailure("Page loaded that neither goes before or after already loaded pages")
                    return
                }
                self?.collectionView.reloadData()
            } else {
                print(errorMessage)
            }
        })
    }
    
    /**
     Goal: Remove the farthest photos from our current location in the search
    */
    private func removePicturesOnMemoryWarning() {
        let firstPageDistance = self.pagePointer - self.firstPageLoaded
        let lastPageDistance = self.lastPageLoaded - self.pagePointer
        if firstPageDistance > lastPageDistance {
            // we're farther from the beginning, so remove the first page
            self.searchResults.removeFirst(Constants.Flickr.resultsPerPage)
            self.firstPageLoaded += 1
        } else {
            // we're farther from the end, so remove the end
            self.searchResults.removeLast(Constants.Flickr.resultsPerPage)
            self.lastPageLoaded -= 1
        }
        self.collectionView.reloadData()
    }
}

extension FlickrSearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // update page & picture pointer, paginate if necessary
        self.updatePages(currentRow: indexPath.row)
        
        // update the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.flickrCell,
                                                      for: indexPath) as! FlickrCollectionViewCell
        
        switch indexPath.row % 2 {
        case 0:
            cell.backgroundColor = Constants.Color.blue
        default:
            cell.backgroundColor = Constants.Color.pink
        }
        cell.setNewContent(content: self.searchResults[indexPath.row])
        
        return cell
    }
    
    private func updatePages(currentRow: Int) {
        self.picturePointer = currentRow  // set the current pic we are viewing
        self.pagePointer = (self.picturePointer / Constants.Flickr.resultsPerPage) + 1  // set the current page based on the pic we are viewing
        let shouldLoadNextPage = self.picturePointer == (self.searchResults.count - 1)
        let shouldLoadPreviousPage = self.picturePointer == 0 && self.firstPageLoaded > 1
        if shouldLoadNextPage {  // if we are at the last picture
            if let searchText = self.searchBar.text, searchText != "" {
                self.search(searchText: searchText, newPageNumber: self.lastPageLoaded + 1)
            }
        } else if shouldLoadPreviousPage {
            if let searchText = self.searchBar.text, searchText != "" {
                self.search(searchText: searchText, newPageNumber: self.firstPageLoaded - 1)
            }
        } //else do nothing
    }
}

extension FlickrSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openImage(currentRow: indexPath.row)
    }
    
    private func openImage(currentRow: Int) {
        let imageVC = ImageDetailViewController()
        imageVC.flickrPhoto = searchResults[currentRow]
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
}

extension FlickrSearchViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let itemsPerRowCGFloat = CGFloat.init(itemsPerRow)
        let horizontalPaddingSpace = sectionInsets.left * (itemsPerRowCGFloat + 1)
        let availableWidth = view.frame.width - horizontalPaddingSpace
        let verticalPaddingSpace = sectionInsets.top + sectionInsets.bottom
        let availableHeight = view.frame.height - verticalPaddingSpace
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        if itemsPerRow == 2 {
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
            let dimension = availableWidth / itemsPerRowCGFloat < availableHeight ? availableWidth / itemsPerRowCGFloat : availableHeight
            width = dimension
            height = dimension
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

extension FlickrSearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
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
