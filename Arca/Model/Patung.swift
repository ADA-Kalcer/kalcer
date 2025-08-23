//
//  Patung.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 15/08/25.
//

import Foundation

enum RecentSource {
    case annotate
    case search
}

struct Patung: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let alias: String?
    let address: String?
    let image: String?
    let longitude: Float?
    let latitude: Float?
    let inaugurationYear: Int?
    let buildReason: String?
    let dimension: String?
    let story: String?
    let artist: String?
    let material: String?
    let category1: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    // Relationships
    var media: [PatungMedia]?
    var materials: [PatungMaterial]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, alias, address, image, longitude, latitude, dimension, story, artist, material, category1
        case inaugurationYear = "inauguration_year"
        case buildReason = "build_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case media = "patung_media"
        
    }
    
    var displayImageUrl: String? {
        // Priority 1: First photo from media array
        if let media = media,
           let firstPhoto = media.first(where: { $0.isPhoto && $0.url != nil }) {
            return firstPhoto.url
        }
        
        // Priority 2: Fallback to single image field
        return image
    }
}
