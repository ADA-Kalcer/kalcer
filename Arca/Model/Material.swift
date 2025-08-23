//
//  Material.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 20/08/25.
//

import Foundation

struct Material: Codable, Identifiable, Hashable {
      let id: UUID
      let name: String
      let createdAt: Date
      let updatedAt: Date

   enum CodingKeys: String, CodingKey {
          case id, name
          case createdAt = "created_at"
          case updatedAt = "updated_at"
      }
  }
