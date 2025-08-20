//
//  PatungDetailView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 19/08/25.
//

import SwiftUI

struct PatungDetailView: View {
    let patung: Patung
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: patung.image ?? "")) { image
                    in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        )
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(patung.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let alias = patung.alias {
                        Text(alias)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                    DetailCard(title: "Address", value: patung.address ?? "Not specified")
                    DetailCard(title: "Artist", value: patung.artist ?? "Unknown")
                    DetailCard(title: "Material", value: patung.material ?? "Not specified")
                    DetailCard(title: "Inauguration Year", value: patung.inaugurationYear != nil ? String(patung.inaugurationYear!) : "Unknown")
                    DetailCard(title: "Dimension", value: patung.dimension ?? "Not specified")
                    
                    if let longitude = patung.longitude, let latitude =
                        patung.latitude {
                        DetailCard(title: "Coordinates", value: "\(latitude), \(longitude)")
                    }
                }
                
                // Story Section
                if let story = patung.story {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Story")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(story)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Build Reason Section
                if let buildReason = patung.buildReason {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Build Reason")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(buildReason)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(patung.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    PatungDetailView(patung: Patung(
        id: UUID(),
        name: "Sample Patung",
        alias: "Sample Alias",
        address: "Sample Address",
        image: nil,
        longitude: 115.0,
        latitude: -8.0,
        inaugurationYear: 2020,
        buildReason: "Sample reason",
        dimension: "10m x 5m",
        story: "Sample story about the patung",
        artist: "Sample Artist",
        material: "Bronze",
        createdAt: Date(),
        updatedAt: Date(),
        deletedAt: nil
    ))
}
