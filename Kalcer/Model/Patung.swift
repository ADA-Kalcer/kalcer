//
//  Patung.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 15/08/25.
//

import Foundation
import Supabase
import MapKit

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
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, alias, address, image, longitude, latitude, dimension, story, artist, material
        case inaugurationYear = "inauguration_year"
        case buildReason = "build_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
