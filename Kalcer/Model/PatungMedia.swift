//
//  PatungMedia.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 20/08/25.
//

import Foundation

struct PatungMedia: Codable, Identifiable, Hashable {
      let id: UUID
      let patungId: UUID
      let type: Int?
      let url: String?

      // Optional relationship
      var mediaType: MediaType?

      enum CodingKeys: String, CodingKey {
          case id, type, url
          case patungId = "patung_id"
          case mediaType = "media_type"
      }

      var isPhoto: Bool {
          return type == MediaType.photo
      }

      var isVideo: Bool {
          return type == MediaType.video
      }
  }
