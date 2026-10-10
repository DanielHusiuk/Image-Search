//
//  ApiManager.swift
//  Image Search
//
//  Created by Daniel Husiuk on 07.10.2026.
//

import UIKit

enum DataError: Error {
    case invalidData
    case invalidResponse
    case message(_ error: Error?)
}

protocol ApiManagerProtocol: AnyObject {
    func fetchData(
        url: URL,
        completion: @escaping (Result<ImageResponse, Error>) -> Void
    )
}

final class ApiManager: ApiManagerProtocol {
    
    func fetchData(
        url: URL,
        completion: @escaping (Result<ImageResponse, Error>) -> Void
    ) {        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(DataError.message(error)))
                }
                return
            }
            
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(DataError.invalidData))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(DataError.invalidResponse))
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(ImageResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DataError.message(error)))
                }
                return
            }
        }.resume()
    }
}
