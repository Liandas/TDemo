//
//  MockNetwork.swift
//  TDemo
//
//  Created by Arda Doğantemur on 1.05.2025.
//

import Foundation


class MockNetwork: Network {

    var result: Result<Data, AppError>?
    
    func doRequest(urlString: String, method: HTTPMethod, body: Data?, headers: [String: String]?, completion: @escaping (Result<Data, AppError>) -> Void) {
        if let result = result {
            completion(result)
        }
    }
}
