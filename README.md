# Flickr Search

## To Run:

1. Add a `Configuration.plist` file in the **FlickrSearch/** directory.  
2. In `Configuration.plist`
    1. Add a `Dictionary` object named "FlickrAPI" under the `Root` object.  
    2. Add two keys under "FlickrAPI" named "ClientID" and "ClientSecret" with their values being your Flickr credentials retrieved [here](https://www.flickr.com/services/api/misc.api_keys.html).
3. Run from Xcode


## Features (High Level)
- Searches the Flickr API using the 'text' query param
- For any given search, infinitely scroll to view all matching photos
- 'Star' your favorite photos. Favorite photos are persisted even after you quit the app.
- Works on iPhone and iPad
- Rotation supported

## Features (Technical)
- Written in Swift
- Completely Programmatic UI (i.e. no Storyboards/IB)
- Built without using Autolayout (as an exercise, not becuase I didn't feel like it)
- Runs on iPhone and iPad
- UICollectionView for displaying images
    - Custom 'brick' layout on iPad and iPhone (landscape)
- UISearchBar with debounce to prevent too many network calls when typing
- Infinite scrolling/pagination
- Memory Warinngs handled to support infinite scrolling/pagination
- Networking
    - Asynchronous on background thread
    - Images are downloaded on-demand and asynchronously which allows for smooth scrolling and relevant images to be loaded faster
    - As user scrolls, images off the screen pause downloading and images on the screen start/resume downloading
- Persistence layer
    - Stores array in NSUserDefaults
    - Controller only talks to PersistenceService, and PersistenceService talks to NetworkService.  This would enable offline capabilities, but it makes populating stored favorite photos easier
- Custom activity indicator view with custom animation
