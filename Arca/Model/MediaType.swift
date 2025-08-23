//
//  MediaType.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 20/08/25.
//

import Foundation

struct MediaType: Codable, Identifiable, Hashable {
      let id: Int
      let type: String
      let createdAt: Date

      enum CodingKeys: String, CodingKey {
          case id, type
          case createdAt = "created_at"
      }

      static let photo = 1
      static let video = 2
  }
