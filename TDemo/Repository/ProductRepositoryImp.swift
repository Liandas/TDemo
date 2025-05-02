//
//  ProductRepositoryImp.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//
import Foundation

class ProductRepositoryImp: ProductRepository
{

    private let networkReachability: NetworkReachability
    private let network: Network
    private let persistence: Persistence
    

    init(network: Network, persistence: Persistence, reachability: NetworkReachability = NetworkReachabilityImp.shared) {
        self.network = network
        self.persistence = persistence
        self.networkReachability = reachability
    }
    
    func fetchProducts(completion: @escaping (Result<[Product], AppError>,DataSource) -> Void) {
        if networkReachability.isConnected {
            Logger.shared.log("Network available", level: .debug)
            
            let url = APIConstants.productListURL
            
            network.doRequest(urlString: url, method: .GET, body: nil, headers: nil) { result in
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let productResponse = try decoder.decode(ProductResponse.self, from: data)
                        let products = productResponse.products
                        
                        // Save to Core Data
                        self.persistence.insertOrUpdate(products: products) { saveResult in
                            switch saveResult {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(products),.backend)
                                }
                            case .failure(let error):
                                Logger.shared.log("Failed to save products: \(error)", level: .error)
                                DispatchQueue.main.async {
                                    completion(.success(products),.backend)
                                }
                            }
                        }
                    } catch {
                        Logger.shared.log("JSON decoding error: \(error)", level: .error)
                        DispatchQueue.main.async {
                            completion(.failure(AppError.invalidJSON), .backend)
                        }
                    }

                case .failure(let error):
                    Logger.shared.log("Network request failed: \(error)", level: .error)
                    DispatchQueue.main.async {
                        completion(.failure(error),.backend)
                    }
                }
            }
        } else {
            Logger.shared.log("No Network", level: .debug)
            loadProductsFromPersistence(completion: completion)
        }
    }
    
    func fetchProductDetails(productId: String, completion: @escaping (Result<Product, AppError>, DataSource) -> Void) {
        if networkReachability.isConnected {
            Logger.shared.log("Network available", level: .debug)

            let url = APIConstants.productDetailURL(for: productId)

            network.doRequest(urlString: url, method: .GET, body: nil, headers: nil) { result in
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let product = try decoder.decode(Product.self, from: data)

                        
                        self.persistence.insertOrUpdate(products: [product]) { saveResult in
                            switch saveResult {
                            case .success:
                                DispatchQueue.main.async {
                                    completion(.success(product) , .backend)
                                }
                            case .failure(let error):
                                Logger.shared.log("Failed to save product detail: \(error)", level: .error)
                                DispatchQueue.main.async {
                                    completion(.success(product), .backend)
                                }
                            }
                        }

                    } catch {
                        Logger.shared.log("JSON decoding error: \(error)", level: .error)
                        DispatchQueue.main.async {
                            completion(.failure(AppError.invalidJSON), .backend)
                        }
                    }

                case .failure(let error):
                    Logger.shared.log("Network request failed: \(error)", level: .error)
                    DispatchQueue.main.async {
                        completion(.failure(error), .backend)
                    }
                }
            }

        } else {
            Logger.shared.log("No Network", level: .debug)
            loadProductDetailFromPersistence(productId: productId, completion: completion)
        }
    }
    
    private func loadProductsFromPersistence(completion: @escaping (Result<[Product], AppError>,DataSource) -> Void) {
        persistence.read(predicate: nil) { result in
            DispatchQueue.main.async {
                completion(result,.persistence)
            }
        }
    }
    
    private func loadProductDetailFromPersistence(productId: String, completion: @escaping (Result<Product, AppError>, DataSource) -> Void) {
        let predicate = NSPredicate(format: "productID == %@", productId)
        persistence.read(predicate: predicate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    if let product = products.first {
                        completion(.success(product), .persistence)
                    } else {
                        completion(.failure(AppError.noCachedProduct), .persistence)
                    }
                case .failure(let error):
                    completion(.failure(error), .persistence)
                }
            }
        }
    }
}
