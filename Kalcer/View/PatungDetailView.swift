//
//  PatungDetailView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 19/08/25.
//

import SwiftUI

struct PatungDetailView: View {
    let patung: Patung
    @StateObject private var patungViewModel = PatungViewModel()
    @State private var patungMedia: [PatungMedia] = []
    @State private var isLoadingMedia: Bool = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 16) {
                PhotoScrollView(isLoadingMedia: $isLoadingMedia, media: patungMedia)
                
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
        .onAppear {
            loadPatungMedia()
        }
    }
    
    private func loadPatungMedia() {
        isLoadingMedia = true
        Task {
            do {
                if let existingMedia = patung.media, !existingMedia.isEmpty {
                    await MainActor.run {
                        self.patungMedia = existingMedia
                        self.isLoadingMedia = false
                    }
                } else {
                    // Fetch media separately if not included in patung object
                    let media = try await patungViewModel.getMediaForPatung(patung.id)
                    
                    await MainActor.run {
                        self.patungMedia = media
                        self.isLoadingMedia = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMedia = false
                }
                print("Error loading patung media: \(error.localizedDescription)")
            }
        }
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
        deletedAt: nil,
        media: [
            PatungMedia(
                id: UUID(),
                patungId: UUID(),
                type: MediaType.photo,
                url: "https://picsum.photos/400/300?random=1"
            ),
            PatungMedia(
                id: UUID(),
                patungId: UUID(),
                type: MediaType.photo,
                url: "https://picsum.photos/400/300?random=2"
            ),
            PatungMedia(
                id: UUID(),
                patungId: UUID(),
                type: MediaType.photo,
                url: "https://picsum.photos/400/300?random=3"
            )
        ]
    )
    )
}
