//
//  Network.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

protocol Network
{
    func doRequest(urlString:String, method:HTTPMethod,
                        body:Data?,
                     headers:[String:String]?,
                  completion:@escaping (Result<Data,AppError>) -> ())
}
