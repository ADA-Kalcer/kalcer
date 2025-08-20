//
//  PatungMaterial.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 20/08/25.
//

import Foundation

struct PatungMaterial: Codable, Identifiable, Hashable {
      let id: UUID
      let patungId: UUID
      let materialId: UUID

      // Optional relationship
      var material: Material?

      enum CodingKeys: String, CodingKey {
          case id
          case patungId = "patung_id"
          case materialId = "material_id"
          case material = "materials"
      }
  }
