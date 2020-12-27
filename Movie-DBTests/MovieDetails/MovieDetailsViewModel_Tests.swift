//
//  MovieDetailsViewModel_Tests.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 26/12/20.
//

import XCTest
import RxSwift
import RxTest
@testable import Movie_DB

class MovieDetailsViewModel_Tests: XCTestCase {

    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var coreDataStack: CoreDataStack!
    
    var isLoading: TestableObserver<Bool>!
    var showOfflineView: TestableObserver<Bool>!
    var showNoDataLabel: TestableObserver<Bool>!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
        coreDataStack = CoreDataStack.inMemoryCoreDataStack()
        
        isLoading = testScheduler.createObserver(Bool.self)
        showOfflineView = testScheduler.createObserver(Bool.self)
        showNoDataLabel = testScheduler.createObserver(Bool.self)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
    }
    
    func test_initialNoDataState() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        viewModel.isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        XCTAssertRecordedElements(isLoading.events, [false])
        XCTAssertRecordedElements(showOfflineView.events, [false])
        XCTAssertRecordedElements(showNoDataLabel.events, [true])
    }
    
    func test_initialCachedDataState() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        viewModel.isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
                
        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        XCTAssertRecordedElements(isLoading.events, [false])
        XCTAssertRecordedElements(showOfflineView.events, [true])
        XCTAssertRecordedElements(showNoDataLabel.events, [false])
    }
    
    func test_noNetwork_noCachedData_error() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        mockMovieDetailsStore.movieDetailsStoreResult = MovieDetailsStoreResult(dataType: .noData, movieDetails: nil, error: NetworkManagerError.networkFailureError("Network Error"))
        
        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
        
        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovieDetails()

        XCTAssertRecordedElements(isLoading.events, [false, true, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [false])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [true])
    }
    
    func test_validNetwork_liveData_noError() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        let movieDetails = self.stubMovieDetails(id: movieId)
        mockMovieDetailsStore.movieDetailsStoreResult = MovieDetailsStoreResult(dataType: .live, movieDetails: movieDetails, error: nil)
        
        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
        
        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovieDetails()

        XCTAssertRecordedElements(isLoading.events, [false, true, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [false])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
    func test_noNetwork_cachedData_error() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        let movieDetails = self.stubMovieDetails(id: movieId)
        mockMovieDetailsStore.movieDetailsStoreResult = MovieDetailsStoreResult(dataType: .cached, movieDetails: movieDetails, error: NetworkManagerError.networkFailureError("Network Error"))

        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovieDetails()

        XCTAssertRecordedElements(isLoading.events, [false, false, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [true])
        XCTAssertRecordedElements([showOfflineView.events.last!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
    func test_cachedData_liveData_noError() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        let movieDetails = self.stubMovieDetails(id: movieId)
        mockMovieDetailsStore.movieDetailsStoreResult = MovieDetailsStoreResult(dataType: .live, movieDetails: movieDetails, error: nil)

        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovieDetails()

        XCTAssertRecordedElements(isLoading.events, [false, false, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [true])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
    func test_noLiveData_invalidMovieId_error() throws {
        let movieId = "434344"
        let mockMovieDetailsStore = MockMovieDetailsStore()
        let viewModel: MovieDetailsViewModel = MovieDetailsViewModel(movieId: movieId, movieDetailsStore: mockMovieDetailsStore)

        let error = NetworkManagerError.apiErrorResponse(["status_code": 34])
        mockMovieDetailsStore.movieDetailsStoreResult = MovieDetailsStoreResult(dataType: .inValid, movieDetails: nil, error: error)

        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovieDetails()

        XCTAssertRecordedElements(isLoading.events, [false, false, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [true])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }

}

extension MovieDetailsViewModel_Tests {
    func stubMovieDetails(id: String) -> MovieDetails {
        let movieDetails = MovieDetails(context: self.coreDataStack.backgroundContext)
            
        movieDetails.id = id
        movieDetails.overview = "overview"
        movieDetails.posterPath = "posterPath"
        movieDetails.title = "title"
        movieDetails.originalLanguage = "en"
        
        return movieDetails
    }
}
