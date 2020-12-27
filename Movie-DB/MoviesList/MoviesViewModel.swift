//
//  MoviesViewModel.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import RxSwift
import RxRelay

class MoviesViewModel {
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isRefreshing = BehaviorRelay<Bool>(value: false)
    
    let _dataType: BehaviorRelay<DataType> = BehaviorRelay<DataType>(value: .noData)
    let error = PublishRelay<Error?>()
    
    lazy var showOfflineView: Observable<Bool> = {
        Observable
            .combineLatest(self._dataType, self.isLoading, self.isRefreshing)
            .map { element in
                if element.0 == .cached, !element.1, !element.2 {
                    return true
                } else {
                    return false
                }
            }
    }()
    
    lazy var showNoDataLabel: Observable<Bool> = {
        Observable
            .combineLatest(self._dataType, self.isLoading)
            .map { element in
                if element.0 == .noData, !element.1 {
                    return true
                } else {
                    return false
                }
            }
    }()

    var category: Endpoints.Movies.Category = .popular
    
    private let moviesStore: MoviesStoreProtocol
    
    let disposeBag = DisposeBag()
    
    init(moviesStore: MoviesStoreProtocol = MoviesStore()) {
        self.moviesStore = moviesStore
        
//        let initialDataType: DataType = moviesStore.getPersistedMoviesCount() > 0 ? .cached : .noData
//        self._dataType = BehaviorRelay<DataType>(value: initialDataType)
        
        moviesStore
            .networkStatus
            .withLatestFrom(self._dataType, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] element in
                guard element.0, element.1 == .noData else { return }
                self?.getMovies()
            })
            .disposed(by: disposeBag)        
    }
    
    func loadMoviesIfNeeded() {
        let dataType = self._dataType.value
        
        guard dataType == .cached else { return }
        self.getMovies()
    }
        
    func getMovies() {
        let dataType = self._dataType.value
        self.isRefreshing.accept(dataType != .noData)
        self.isLoading.accept(dataType == .noData)
        
        moviesStore.getMovies(category: category) { [weak self] storeState in
            self?.isLoading.accept(false)
            self?.isRefreshing.accept(false)
            self?._dataType.accept(storeState.dataType)
            
            guard let error = storeState.error else { return }
            self?.error.accept(error)
        }
    }
    
}
