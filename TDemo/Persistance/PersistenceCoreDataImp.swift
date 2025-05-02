//
//  Persistance.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

import Foundation
import CoreData

class PersistenceCoreDataImp :Persistence{
    
    func create(products: [Product], completion: @escaping (Result<Bool, AppError>) -> Void) {
        let context = backgroundContext
        
        context.perform {
            for product in products {
                _ = ProductEntity.create(from: product, in: context)
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceError))
                }
            }
        }
    }
    
    func update(products: [Product], completion: @escaping (Result<Bool, AppError>) -> Void) {
        let context = backgroundContext

        context.perform {
            for product in products {
                let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "productID == %@", product.productID)
                fetchRequest.fetchLimit = 1
                
                do {
                    if let entity = try context.fetch(fetchRequest).first {
                        entity.name = product.name
                        entity.price = product.price ?? 0
                        entity.imageUrl = product.urlString
                        entity.detail = product.detail
                    } else {
                        Logger.shared.log("ProductEntity with ID \(product.productID) not found for update.", level: .warning)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.persistenceError))
                    }
                    return
                }
            }
            
            do {
                if context.hasChanges {
                    try context.save()
                }
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceError))
                }
            }
        }
    }
    
    func delete(predicate: NSPredicate?, completion: @escaping (Result<Bool, AppError>) -> Void) {
        let context = backgroundContext

        context.perform {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            request.predicate = predicate

            do {
                let objectsToDelete = try context.fetch(request)

                for object in objectsToDelete {
                    context.delete(object)
                }

                if context.hasChanges {
                    try context.save()
                }

                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceError))
                }
            }
        }
    }
    
    func insertOrUpdate(products: [Product], completion: @escaping (Result<Bool, AppError>) -> Void) {
        let context = backgroundContext

        context.perform {
            for product in products {
                let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "productID == %@", product.productID)
                fetchRequest.fetchLimit = 1

                do {
                    if let existing = try context.fetch(fetchRequest).first {
                        // Update
                        existing.name = product.name
                        existing.price = product.price ?? 0
                        existing.imageUrl = product.urlString
                        existing.detail = product.detail
                    } else {
                        // Create
                        _ = ProductEntity.create(from: product, in: context)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.persistenceError))
                    }
                    return
                }
            }

            do {
                if context.hasChanges {
                    try context.save()
                }
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceError))
                }
            }
        }
    }
    
    func read(predicate: NSPredicate?, completion: @escaping (Result<[Product], AppError>) -> Void) {
        let context = backgroundContext
        
        context.perform {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            request.predicate = predicate
            
            do {
                let entities = try context.fetch(request)
                let products = entities.map { $0.toProduct() }
                DispatchQueue.main.async {
                    completion(.success(products))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceError))
                }
            }
        }
    }
    
    
    let persistentContainer: NSPersistentContainer
    static let shared = PersistenceCoreDataImp()

    // MARK: - Context
    // ===============================================================================
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "TDemo")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        
        if let storeDescription = persistentContainer.persistentStoreDescriptions.first,
           let _ = storeDescription.url {}
        else {
        }
    }
}
