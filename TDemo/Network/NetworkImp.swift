//
//  NetworkServiceImp.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//
import Foundation

// MARK: - Network Service
// ===============================================================================
class NetworkImp: Network
{
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func doRequest(urlString:String,
                      method:HTTPMethod,
                        body:Data? = nil,
                     headers:[String:String]? = nil,
                  completion:@escaping (Result<Data,AppError>) -> ())
    {
        guard let url = URL(string: urlString) else {
            completion(.failure(AppError.invalidURL))
            return
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request) { data, response, error in
            if let errorWR = error
            {
                completion(.failure(AppError.networkError(errorWR.localizedDescription)))
                return
            }
            
            guard let dataWR = data else
            {
                completion(.failure(AppError.noData))
                return
            }
            
            DispatchQueue.main.async{
                completion(.success(dataWR))
            }
            
        }.resume()
    }
}
