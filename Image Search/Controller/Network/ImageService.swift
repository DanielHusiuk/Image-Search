//
//  ImageService.swift
//  Image Search
//
//  Created by Daniel Husiuk on 07.10.2026.
//

import Foundation

protocol ImageServiceProtocol {
    func searchImages(
        searchText: String,
        completion: @escaping (Result<ImageResponse, Error>) -> Void
    )
}

final class ImageService: ImageServiceProtocol {
    
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "PIXABAY_API_KEY") as? String ?? ""
    private let baseUrl = "https://pixabay.com/api/"
    private let apiManager: ApiManagerProtocol
    
    init(apiManager: ApiManagerProtocol) {
        self.apiManager = apiManager
    }
    
    func searchImages(searchText: String, completion: @escaping (Result<ImageResponse, Error>) -> Void) {
        
        var fullUrl = URLComponents(string: baseUrl)
        fullUrl?.queryItems = [
            URLQueryItem(name: "key", value: "\(apiKey)"),
            URLQueryItem(name: "q", value: searchText),
            URLQueryItem(name: "image_type", value: "photo"),
            URLQueryItem(name: "safesearch", value: "true"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "200")
        ]
        
        guard let url = fullUrl?.url else {
            DispatchQueue.main.async {
                completion(.failure(DataError.invalidData))
            }
            return
        }
        
        apiManager.fetchData(url: url, completion: completion)
    }
    
}
