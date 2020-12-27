//
//  MoviesStore.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import RxSwift
import CoreData
import RxRelay

enum DataType {
    case live
    case cached
    case noData
    case inValid
}

struct MoviesStoreResult {
    let dataType: DataType
    let error: Error?
}

protocol MoviesStoreProtocol {
    var networkStatus: PublishRelay<Bool> { get }
    func getPersistedMoviesCount() -> Int
    func getMovies(category: Endpoints.Movies.Category, completionHandler: ((MoviesStoreResult) -> Void)?)
}

class MoviesStore: MoviesStoreProtocol {
    
    private let coreDataStack: CoreDataStack
    private let networkManager: NetworkManagerProtocol
    internal lazy var networkStatus = networkManager.networkStatus

    init(coreDataStack: CoreDataStack = CoreDataStack.sharedInstance, networkManager: NetworkManagerProtocol = NetworkManager.sharedInstance) {
        self.coreDataStack = coreDataStack
        self.networkManager = networkManager
    }
    
    func getMovies(category: Endpoints.Movies.Category, completionHandler: ((MoviesStoreResult) -> Void)?) {
        let endpoint = Endpoints.Movies(category: category)
        
        let backgroundContext = self.coreDataStack.backgroundContext

        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context] = backgroundContext

        let _ = self.networkManager.apiDataTask(endpoint: endpoint, decoder: decoder) { [weak self] (response: Result<Movies?, NetworkManagerError>?) in
            
            var error: Error? = nil
            switch response {
            case .failure(let networkError):
                error = networkError
            case .success(_):
                do {
                    try self?.deleteAllMovies()
                    try self?.coreDataStack.saveContext()
                    
                    if self?.getPersistedMoviesCount() ?? 0 != 0 {
                        completionHandler?(MoviesStoreResult(dataType: .live, error: error))
                    } else {
                        completionHandler?(MoviesStoreResult(dataType: .noData, error: error))
                    }
                    return
                } catch (let coreDataError) {
                    error = coreDataError
                }
            case .none: break
            }
            
            if self?.getPersistedMoviesCount() ?? 0 != 0 {
                completionHandler?(MoviesStoreResult(dataType: .cached, error: error))
                return
            }
            
            completionHandler?(MoviesStoreResult(dataType: .noData, error: error))
        }
    }
    
    func deleteAllMovies() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Movie.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try coreDataStack.backgroundContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [coreDataStack.backgroundContext])
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [coreDataStack.viewContext])
        } catch {
            throw error
        }
    }
    
    func getPersistedMoviesCount() -> Int {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        return (try? coreDataStack.viewContext.count(for: fetchRequest)) ?? 0
    }

}
