//
//  MockPersistence.swift
//  TDemo
//
//  Created by Arda Doğantemur on 1.05.2025.
//

import Foundation


class MockPersistence: Persistence {
    var savedProducts: [Product] = []
    var readResult: Result<[Product], AppError> = .success([])
    var insertShouldFail = false

    func insertOrUpdate(products: [Product], completion: @escaping (Result<Bool, AppError>) -> ()) {
        if insertShouldFail {
            completion(.failure(AppError.persistenceError))
        } else {
            savedProducts = products
            completion(.success(true))
        }
    }

    func read(predicate: NSPredicate?, completion: @escaping (Result<[Product], AppError>) -> ()) {
        completion(readResult)
    }

    func create(products: [Product], completion: @escaping (Result<Bool, AppError>) -> ()) {}
    func update(products: [Product], completion: @escaping (Result<Bool, AppError>) -> ()) {}
    func delete(predicate: NSPredicate?, completion: @escaping (Result<Bool, AppError>) -> ()) {}
}
