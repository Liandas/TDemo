//
//  APIConstants.swift
//  TDemo
//
//  Created by Arda Doğantemur on 30.04.2025.
//


struct APIConstants {

    static let baseURL = "https://s3-eu-west-1.amazonaws.com/developer-application-test/cart"
    
    static var productListURL: String {
        return "\(baseURL)/list"
    }
    
    static func productDetailURL(for id: String) -> String {
        return "\(baseURL)/\(id)/detail"
    }
}
