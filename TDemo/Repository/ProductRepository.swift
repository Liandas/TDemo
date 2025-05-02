//
//  ProductRepository.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//



protocol ProductRepository {
    func fetchProducts(completion: @escaping (Result<[Product],AppError>,DataSource) -> Void)
    func fetchProductDetails(productId:String, completion: @escaping (Result<Product,AppError>,DataSource) -> Void)
}
