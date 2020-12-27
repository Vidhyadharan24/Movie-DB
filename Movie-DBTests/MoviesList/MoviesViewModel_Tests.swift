//
//  MoviesViewModel_Tests.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 26/12/20.
//

import XCTest
import RxSwift
import RxTest
@testable import Movie_DB

class MoviesViewModel_Tests: XCTestCase {
    var testScheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var isLoading: TestableObserver<Bool>!
    var isRefreshing: TestableObserver<Bool>!
    var showOfflineView: TestableObserver<Bool>!
    var showNoDataLabel: TestableObserver<Bool>!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
        
        isLoading = testScheduler.createObserver(Bool.self)
        isRefreshing = testScheduler.createObserver(Bool.self)
        showOfflineView = testScheduler.createObserver(Bool.self)
        showNoDataLabel = testScheduler.createObserver(Bool.self)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        testScheduler = nil
    }
    
    // TODO: Test class naming convention could have been better
    
    func test_initialNoDataState() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore()
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)

        viewModel.isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        XCTAssertRecordedElements(isLoading.events, [false])
        XCTAssertRecordedElements(isRefreshing.events, [false])
        XCTAssertRecordedElements(showOfflineView.events, [false])
        XCTAssertRecordedElements(showNoDataLabel.events, [true])
    }
    
    func test_initialCachedDataState() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore(cachedCount: 10)
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)
                
        viewModel.isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
                
        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        XCTAssertRecordedElements(isLoading.events, [false])
        XCTAssertRecordedElements(isRefreshing.events, [false])
        XCTAssertRecordedElements(showOfflineView.events, [true])
        XCTAssertRecordedElements(showNoDataLabel.events, [false])
    }
    
    func test_noNetwork_noCachedData_error() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore()
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)

        mockMoviesStore.moviesStoreResult = MoviesStoreResult(dataType: .noData, error: NetworkManagerError.networkFailureError("Network Error"))
        
        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
        
        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovies()

        XCTAssertRecordedElements(isLoading.events, [false, true, false])
        XCTAssertRecordedElements(isRefreshing.events, [false, false, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [false])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [true])
    }
    
    func test_validNetwork_liveData_noError() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore()
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)

        mockMoviesStore.moviesStoreResult = MoviesStoreResult(dataType: .live, error: nil)
        
        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)
        
        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovies()

        XCTAssertRecordedElements(isLoading.events, [false, true, false])
        XCTAssertRecordedElements(isRefreshing.events, [false, false, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [false])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
    func test_cachedData_cachedData_error() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore(cachedCount: 10)
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)

        mockMoviesStore.moviesStoreResult = MoviesStoreResult(dataType: .cached, error: NetworkManagerError.networkFailureError("Network Error"))

        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovies()

        XCTAssertRecordedElements(isLoading.events, [false, false, false])
        XCTAssertRecordedElements(isRefreshing.events, [false, true, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [true])
        XCTAssertRecordedElements([showOfflineView.events.last!], [true])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
    func test_cachedData_liveData_error() throws {
        let mockMoviesStore: MockMoviesStore = MockMoviesStore(cachedCount: 10)
        let viewModel: MoviesViewModel = MoviesViewModel(moviesStore: mockMoviesStore)

        mockMoviesStore.moviesStoreResult = MoviesStoreResult(dataType: .live, error: nil)

        viewModel
            .isLoading
            .bind(to: isLoading)
            .disposed(by: self.disposeBag)

        viewModel.isRefreshing
            .bind(to: isRefreshing)
            .disposed(by: self.disposeBag)

        viewModel.showOfflineView
            .bind(to: showOfflineView)
            .disposed(by: self.disposeBag)

        viewModel.showNoDataLabel
            .bind(to: showNoDataLabel)
            .disposed(by: self.disposeBag)

        viewModel.getMovies()

        XCTAssertRecordedElements(isLoading.events, [false, false, false])
        XCTAssertRecordedElements(isRefreshing.events, [false, true, false])
        XCTAssertRecordedElements([showOfflineView.events.first!], [true])
        XCTAssertRecordedElements([showOfflineView.events.last!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.first!], [false])
        XCTAssertRecordedElements([showNoDataLabel.events.last!], [false])
    }
    
}
