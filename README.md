# Movie-DB

The app is built using the MVVM + RxSwift architecture with offline support via coredata persistant storage. The app fetches movies and movie details from the TMDB database.

Installation

The app relies on three external libraries,
Kingfisher - For loading images
Reachability - For monitoring network availabilty change
RxSwift - For reactive programming.

Both Kingfisher and Reachablity are added using the Swift Package Manager, for these no additional steps are required to run the app


Due to an [issue](https://github.com/ReactiveX/RxSwift#swift-package-manager) with Swift Package Manger with RxSwift, the package is installed using carthage.

Cocoapods

To install run `sudo gem install cocoapods`
once installed go to the projects root directory and run pod install, open the Movie-DB.xcworkspace to run the app.
