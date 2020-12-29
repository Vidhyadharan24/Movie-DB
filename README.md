# Movie-DB

The app is built using the MVVM + RxSwift architecture with offline support via coredata persistant storage. The app fetches movies and movie details from the TMDB database.

Installation

The app relies on three external libraries,
Kingfisher - For loading images
Reachability - For monitoring network availabilty change
RxSwift - For reactive programming.

Both Kingfisher and Reachablity are added using the Swift Package Manager, for these no additional steps are required to run the app


Due to an [issue](https://github.com/ReactiveX/RxSwift#swift-package-manager) with Swift Package Manger with RxSwift, the package is installed using carthage.

## Cocoapods

To install run `sudo gem install cocoapods`
once installed go to the projects root directory and run pod install, open the Movie-DB.xcworkspace to run the app.


Funtionality
## MoviesList

The page by default loads the popular movies from the TMDB database and caches it to coredata for offline usage, when the app is offline an bar is show to indicate that the current movie data is cached data. Using network monitoring if there is nodata the app reload the movies list.

## MovieDetails
The page loads the cached movie details when the live data api call fails for any reason, an offline bar is shown when the displyed data is cached data. The page auto reloads the movie details when the device is back online by monitoring the network status.


## Unit Testing
Unit testing for the MoviesDataStore and MovieDetailsDataStore (Model) is done via expections, testing MoviesViewModel and MovieDetailsViewModel is achevied via RxTest framework and TestableObserver class. 

## Swift UI version [Github](https://github.com/Vidhyadharan24/Movie-DB-SwiftUI)
The Swift UI version of this app is a work in progress, more feature will be added later on.
