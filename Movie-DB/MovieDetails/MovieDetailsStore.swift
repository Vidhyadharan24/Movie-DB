//
//  MovieDetailsStore.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import CoreData
import RxRelay

struct MovieDetailsStoreResult {
    let dataType: DataType
    let movieDetails: MovieDetails?
    let error: Error?
}

protocol MovieDetailsStoreProtocol {
    var networkStatus: PublishRelay<Bool> { get }
    func getMovieDetails(id: String, completionHandler: ((MovieDetailsStoreResult) -> Void)?)
}

class MovieDetailsStore: MovieDetailsStoreProtocol {
    
    let coreDataStack: CoreDataStack
    let networkManager: NetworkManagerProtocol
    lazy var networkStatus: PublishRelay<Bool> = networkManager.networkStatus

    init(coreDataStack: CoreDataStack = CoreDataStack.sharedInstance,
         networkManager: NetworkManagerProtocol = NetworkManager.sharedInstance) {
        self.coreDataStack = coreDataStack
        self.networkManager = networkManager
    }

    func getMovieDetails(id: String, completionHandler: ((MovieDetailsStoreResult) -> Void)?) {
        let endpoint = Endpoints.MovieDetails(movieId: id)

        let backgroundContext = self.coreDataStack.backgroundContext
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context] = backgroundContext

        let _ = self.networkManager.apiDataTask(endpoint: endpoint, decoder: decoder) { [weak self] (response: Result<MovieDetails?, NetworkManagerError>?) in

            var error: Error? = nil
            
            switch response {
            case .failure(let networkError):
                switch networkError {
                case .apiErrorResponse(let dictionary):
                    if let code = dictionary["status_code"] as? Int, code == 34 {
                        completionHandler?(MovieDetailsStoreResult(dataType: .inValid, movieDetails: nil, error: networkError))
                        return
                    }
                default: break
                }
                error = networkError
            case .success(let optionalDetails):
                do {
                    guard let movieDetails = optionalDetails, let details = try self?.saveMovieDetailsToDB(movieDetails: movieDetails) else { break }
                    completionHandler?(MovieDetailsStoreResult(dataType: .live, movieDetails: details, error: error))
                    return
                } catch (let coreDataError) {
                    error = coreDataError
                }
            case .none:
                break
            }
                        
            do {
                if let details = try self?.getMovieDetailsFromDB(id: id) {
                    completionHandler?(MovieDetailsStoreResult(dataType: .cached, movieDetails: details, error: error))
                    return
                }
            } catch (let coreDataError) {
                error = coreDataError
            }
            
            completionHandler?(MovieDetailsStoreResult(dataType: .noData, movieDetails: nil, error: error))
        }
    }
    
    // TODO: Would be better to put these helper methods in an extension
    private func saveMovieDetailsToDB(movieDetails: MovieDetails) throws -> MovieDetails? {
        let backgroundContext = self.coreDataStack.backgroundContext
        let id = movieDetails.id!
        do {
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                        
            if let movie = try backgroundContext.fetch(fetchRequest).first {
                movie.details = movieDetails
            }
        } catch {
            throw error
        }
        
        try coreDataStack.saveContext()
        return try getMovieDetailsFromDB(id: id)
    }
    
    private func getMovieDetailsFromDB(id: String) throws -> MovieDetails? {
        let viewContext = self.coreDataStack.viewContext
        
        let fetchRequest: NSFetchRequest<MovieDetails> = MovieDetails.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                
        return try viewContext.fetch(fetchRequest).first
    }
    
}
