//
//  MovieDetailsViewModel.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import RxSwift
import RxRelay

class MovieDetailsViewModel {

    private let movieId: String
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let dataType = BehaviorRelay<DataType>(value: .noData)
    let movieDetails = BehaviorRelay<MovieDetails?>(value: nil)

    lazy var showOfflineView: Observable<Bool> = {
        Observable
            .combineLatest(self.dataType, self.isLoading, self.movieDetails)
            .map { element in
                if element.0 == .cached, !element.1, element.2 != nil {
                    return true
                } else {
                    return false
                }
            }
    }()
    
    lazy var showDetailsView: Observable<Bool> = {
        Observable
            .combineLatest(self.movieDetails, self.isLoading)
            .map { element in
                if element.0 != nil, !element.1 {
                    return false
                } else {
                    return true
                }
            }
    }()
    
    lazy var showNoDataLabel: Observable<Bool> = {
        Observable
            .combineLatest(self.movieDetails, self.isLoading)
            .map { element in
                if element.0 == nil, !element.1 {
                    return true
                } else {
                    return false
                }
            }
    }()

    var error = PublishRelay<Error>()
    
    let movieDetailsStore: MovieDetailsStoreProtocol
    
    let disposeBag = DisposeBag()
    
    init(movieId: String, movieDetailsStore: MovieDetailsStoreProtocol = MovieDetailsStore()) {
        self.movieId = movieId
        self.movieDetailsStore = movieDetailsStore
        
        self.movieDetailsStore
            .networkStatus
            .withLatestFrom(self.dataType, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] element in
                guard element.0, element.1 != .live else { return }
                self?.getMovieDetails()
            })
            .disposed(by: disposeBag)
        
        getMovieDetails()
    }

    func getMovieDetails() {
        self.isLoading.accept(true)
        
        movieDetailsStore.getMovieDetails(id: self.movieId) { [weak self] storeState in
            self?.isLoading.accept(false)
            self?.dataType.accept(storeState.dataType)
            self?.movieDetails.accept(storeState.movieDetails)
            
            guard let error = storeState.error else { return }
            self?.error.accept(error)
        }
    }
}
