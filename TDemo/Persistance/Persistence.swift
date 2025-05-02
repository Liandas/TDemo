//
//  Persistances.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

import Foundation


protocol Persistence {
    func create(products:[Product], completion: @escaping (Result<Bool,AppError>) -> ())
    func read(predicate: NSPredicate?, completion: @escaping (Result<[Product],AppError>) -> ())
    func update(products: [Product], completion: @escaping (Result<Bool,AppError>) -> ())
    func delete(predicate: NSPredicate?, completion: @escaping (Result<Bool,AppError>) -> ())
    
    func insertOrUpdate(products: [Product], completion: @escaping (Result<Bool,AppError>) -> ())

}
