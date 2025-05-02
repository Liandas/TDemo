//
//  ProductEntity+CoreDataProperties.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//
//

import Foundation
import CoreData


extension ProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }

    @NSManaged public var detail: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var productID: String

    func toProduct() -> Product
    {
        return Product(productID: productID, name: name, price: price, urlString: imageUrl, detail: detail)
    }
    
    static func create(from product: Product, in context: NSManagedObjectContext) -> ProductEntity {
        let entity = ProductEntity(context: context)
        entity.productID = product.productID
        entity.name = product.name
        entity.price = product.price ?? 0
        entity.imageUrl = product.urlString
        entity.detail = product.detail
        return entity
    }
}

extension ProductEntity : Identifiable {

}
