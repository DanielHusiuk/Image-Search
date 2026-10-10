//
//  ImageResponse.swift
//  Image Search
//
//  Created by Daniel Husiuk on 07.10.2026.
//

import Foundation

struct ImageResponse: Codable {
    let total: Int
    let totalHits: Int
    let hits: [ImageModel]
}
