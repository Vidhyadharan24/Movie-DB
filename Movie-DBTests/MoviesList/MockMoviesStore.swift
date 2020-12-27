//
//  MockMoviesStore.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 26/12/20.
//

import UIKit
import RxRelay
@testable import Movie_DB

class MockMoviesStore: MoviesStoreProtocol {
    let networkStatus = BehaviorRelay<Bool>(value: false)
    
    var cachedMoviesCount = 0
    var moviesStoreResult: MoviesStoreResult = MoviesStoreResult(dataType: .noData, error: nil)
    
    init(cachedCount: Int = 0) {
        self.cachedMoviesCount = cachedCount
    }
    
    func getPersistedMoviesCount() -> Int {
        return self.cachedMoviesCount
    }
    
    func getMovies(category: Endpoints.Movies.Category, completionHandler: ((MoviesStoreResult) -> Void)?) {
        completionHandler?(moviesStoreResult)
    }
    

}
