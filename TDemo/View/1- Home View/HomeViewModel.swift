//
//  HomeViewModel.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//

import Foundation

class HomeViewModel
{
    private let repository: ProductRepository
    
    var onProductsUpdated: (([Product], DataSource) -> Void)?
    var onError: ((AppError, DataSource) -> Void)?
    
    private(set) var products: [Product] = []

    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func getProducts()
    {
        repository.fetchProducts { [weak self] result , source in
            switch result {
            case .success(let products):
                self?.products = products
                self?.onProductsUpdated?(products,source)
            case .failure(let error):
                self?.onError?(error, source)
            }
        }
    }
}
