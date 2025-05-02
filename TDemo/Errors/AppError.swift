//
//  AppError.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//


enum AppError: Error, Equatable {
    
    // Network
    case invalidURL
    case networkError(String)
    case decodingError
    case invalidJSON
    case noData
    
    // Persistance
    case persistenceError
    case noCachedProduct
    case unknown
    

    var userMessage: String {
        switch self {
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .decodingError:
            return "Failed to process server data."
        case .persistenceError:
            return "Could not access saved data."
        case .invalidURL:
            return "Invalid URL."
        case .invalidJSON:
            return "Invalid JSON."
        case .unknown:
            return "An unexpected error occurred."
        case .noData:
            return "No Data"
        case .noCachedProduct:
            return "No cached product"
        }
    }
}
