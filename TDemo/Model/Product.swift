//
//  ProductDetail.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

struct Product:Codable {

    var productID:String
    var name:String?
    var price:Double?
    var urlString:String?
    var detail:String?
    
    enum CodingKeys: String,CodingKey {
        case productID = "product_id"
        case name = "name"
        case price = "price"
        case urlString = "image"
        case detail = "description"
    }
}

struct ProductResponse: Codable {
    let products: [Product]
}
   
