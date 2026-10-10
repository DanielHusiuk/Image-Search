//
//  ImageModel.swift
//  Image Search
//
//  Created by Daniel Husiuk on 07.10.2026.
//

import Foundation

struct ImageModel: Codable {
    let id: Int
    let tags: String
    let previewURL: String
    let webformatURL: String
    let largeImageURL: String
    let user: String
}
