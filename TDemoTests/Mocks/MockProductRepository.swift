//
//  MockProductRepository.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//

import Foundation

class MockProductRepository: ProductRepository {
    var productsToReturn: [Product] = []
    var productDetailToReturn: Product?
    var errorToReturn: AppError?

    func fetchProducts(completion: @escaping (Result<[Product],AppError>,DataSource) -> Void)
    {
        if let error = errorToReturn {
            completion(.failure(error), .backend)
        } else {
            completion(.success(productsToReturn), .backend)
        }
    }

    func fetchProductDetails(productId: String, completion: @escaping (Result<Product, AppError>, DataSource) -> Void) {
        if let error = errorToReturn {
            completion(.failure(error),.backend)
        } else if let product = productDetailToReturn {
            completion(.success(product), .backend)
        }
    }
}
