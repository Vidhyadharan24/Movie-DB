//
//  MockNetworkManagerStack.swift
//  Movie-DBTests
//
//  Created by Vidhyadharan on 26/12/20.
//

import UIKit
import RxRelay
@testable import Movie_DB

class MockNetworkManager: NetworkManagerProtocol {
    let networkStatus = BehaviorRelay<Bool>(value: false)
    
    var failureError: NetworkManagerError? = nil
    var successObject: AnyObject? = nil
    
    func apiDataTask<T>(endpoint: EndPoint, decoder: JSONDecoder, completion: @escaping (Result<T?, NetworkManagerError>) -> Void) where T : Decodable, T : Encodable {
        guard self.failureError == nil else {
            completion(.failure(self.failureError!))
            return
        }
        
        completion(.success(self.successObject as? T))
    }
}
