//
//  NetworkManager.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import CoreData
import Reachability
import RxRelay

enum NetworkManagerError: Error {
    case networkFailureError(String)
    case apiErrorResponse([String: Any])
    case decodeError(String)
}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

protocol NetworkManagerProtocol {
    // Instead of relay should have used notification.
    var networkStatus: PublishRelay<Bool> { get }
    
    func apiDataTask<T: Codable>(endpoint: EndPoint,
                     decoder: JSONDecoder,
                     completion: @escaping (Result<T?, NetworkManagerError>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    static let sharedInstance = NetworkManager()
    
    private let reachability = try! Reachability()

    let networkStatus = PublishRelay<Bool>()
    
    private init() {

        reachability.whenReachable = { reachability in
            self.networkStatus.accept(true)
        }
        
        reachability.whenUnreachable = { _ in
            self.networkStatus.accept(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    fileprivate var sessionConfig: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return config
    }()

    internal lazy var session: URLSession = {
        let session: URLSession = URLSession(configuration: sessionConfig)
        return session
    }()

    func apiDataTask<T: Codable>(endpoint: EndPoint,
                     decoder: JSONDecoder,
                     completion: @escaping (Result<T?, NetworkManagerError>) -> Void) {

        let dataTask: URLSessionDataTask = session.dataTask(with: endpoint.urlRequest()) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkManagerError.networkFailureError(error!.localizedDescription)))
                }
                return
            }
                        
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 else {
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
                return
            }
            
            var jsonDecodeError: Error
            do {
                let obj = try decoder.decode(T.self, from: data!)
                DispatchQueue.main.async {
                    completion(.success(obj))
                }
            } catch (let decodeError) {
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                        DispatchQueue.main.async {
                            completion(.failure(NetworkManagerError.apiErrorResponse(dictionary)))
                        }
                        return
                    }
                    jsonDecodeError = decodeError
                } catch let jsonError {
                    jsonDecodeError = jsonError
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NetworkManagerError.decodeError(jsonDecodeError.localizedDescription)))
                }
            }
        }
        
        dataTask.resume()
    }

}
