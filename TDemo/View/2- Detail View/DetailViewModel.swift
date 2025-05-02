//
//  DetailViewModel.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//

class DetailViewModel
{
    private let repository: ProductRepository
    
    var onProductUpdated: ((Product,DataSource) -> Void)?
    var onError: ((AppError,DataSource) -> Void)?
    
    private(set) var product: Product

    init(repository: ProductRepository , product:Product) {
        self.repository = repository
        self.product = product
    }
    
    func getProduct()
    {
        repository.fetchProductDetails(productId: product.productID) { result, source in
            switch result {
            case .success(let product):
                self.product = product
                self.onProductUpdated?(product,source)
            case .failure(let error):
                self.onError?(error,source)
            }
        }
    }
}
