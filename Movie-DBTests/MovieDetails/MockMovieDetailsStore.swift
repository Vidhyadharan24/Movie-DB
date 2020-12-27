//
//  MovieDetailsStore.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 26/12/20.
//

import UIKit
import RxRelay
@testable import Movie_DB

class MockMovieDetailsStore: MovieDetailsStoreProtocol {
    let networkStatus = BehaviorRelay<Bool>(value: false)
    
    var movieDetailsStoreResult: MovieDetailsStoreResult = MovieDetailsStoreResult(dataType: .noData, movieDetails: nil, error: nil)
    
    func getMovieDetails(id: String, completionHandler: ((MovieDetailsStoreResult) -> Void)?) {
        completionHandler?(movieDetailsStoreResult)
    }
    
}
