//
//  MovieDetailsStore_Tests.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 23/12/20.
//

import XCTest
import CoreData
@testable import Movie_DB

class MovieDetailsStore_Tests: XCTestCase {

    var coreDataStack: CoreDataStack!
    var mockNetworkManager: MockNetworkManager!
    var movieDetailsStore: MovieDetailsStore!

    override func setUpWithError() throws {
        coreDataStack = CoreDataStack.inMemoryCoreDataStack()
        mockNetworkManager = MockNetworkManager()
        movieDetailsStore = MovieDetailsStore(coreDataStack: coreDataStack, networkManager: mockNetworkManager)
    }

    override func tearDownWithError() throws {
        coreDataStack = nil
        mockNetworkManager = nil
        movieDetailsStore = nil
    }

    func test_noNetwork_noCachedData_error() throws {
        mockNetworkManager.failureError = NetworkManagerError.networkFailureError("Network Error")
        
        let expt = expectation(description: "Should fail on network error")
        movieDetailsStore.getMovieDetails(id: "434233") { response in
            guard let _ = response.error, response.dataType == .noData else { return }
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_noNetwork_cachedData_error() throws {
        mockNetworkManager.failureError = NetworkManagerError.networkFailureError("Network Error")
        
        let id = "345678"
        try insertStubMovieDetails(id: id, shouldSave: true)
        
        let expt = expectation(description: "Should fail on network error")
        movieDetailsStore.getMovieDetails(id: id) { response in
            guard let _ = response.error, response.dataType == .cached else { return }
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_validNetwork_invalidMovieId_error() throws {
        mockNetworkManager.failureError = NetworkManagerError.apiErrorResponse(["status_code" : 34])
        
        let id = "345678"
        
        let expt = expectation(description: "Should fail on due to invalid movie id")
        movieDetailsStore.getMovieDetails(id: id) { response in
            guard let _ = response.error, response.dataType == .inValid else { return }
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_validNetwork_liveData_noError() throws {
        let movieDetails = try insertStubMovieDetails()
        mockNetworkManager.successObject = movieDetails
        
        let expt = expectation(description: "Should fail on due to invalid movie id")
        movieDetailsStore.getMovieDetails(id: movieDetails.id!) { response in
            guard response.error == nil, response.dataType == .live else { return }
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_validNetwork_validMovie_movieDetails_Relationship() throws {
        let id = "434354"
        let movie = try insertStubMovie(id: id)
        let movieDetails = try insertStubMovieDetails(id: id)
        mockNetworkManager.successObject = movieDetails
        
        let expt = expectation(description: "Should fail on due to invalid movie id")
        movieDetailsStore.getMovieDetails(id: movieDetails.id!) { response in
            guard response.error == nil, response.dataType == .live else { return }
            guard movie.details != nil else { return }
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}

// TODO: These helper methods should be in a common class as they are replicated
extension MovieDetailsStore_Tests {
    func insertStubMovie(id: String = NSUUID().uuidString) throws -> Movie {
        let movie = Movie(context: self.coreDataStack.backgroundContext)
            
        movie.id = id
        movie.overview = "overview"
        movie.posterPath = "posterPath"
        movie.title = "title"
        movie.popularity = 300.00
                
        try self.coreDataStack.saveContext()
        
        return movie
    }
    
    @discardableResult func insertStubMovieDetails(id: String = NSUUID().uuidString, shouldSave: Bool = false) throws -> MovieDetails {
        let movieDetails = MovieDetails(context: self.coreDataStack.backgroundContext)
            
        movieDetails.id = id
        movieDetails.overview = "overview"
        movieDetails.posterPath = "posterPath"
        movieDetails.title = "title"
        movieDetails.originalLanguage = "en"
        
        guard shouldSave else { return movieDetails }
        try self.coreDataStack.saveContext()
        
        return movieDetails
    }
    
}
