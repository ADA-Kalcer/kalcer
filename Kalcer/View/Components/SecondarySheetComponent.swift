//
//  SecondarySheetComponent.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import SwiftUI

struct SecondarySheetComponent: View {
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    let selectedPatung: Patung
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                bookmarkPatungViewModel.toggleBookmark(selectedPatung)
            } label: {
                Image(systemName: bookmarkPatungViewModel.isBookmarked(selectedPatung) ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .foregroundStyle(Color.rgb(red: 64, green: 64, blue: 1))
            }
            .padding()
            
            Button {
            } label: {
                Image(systemName: "car")
                    .font(.title2)
                    .foregroundStyle(Color.rgb(red: 64, green: 64, blue: 1))
            }
            .padding()
        }
        .glassEffect(.regular.interactive())
    }
}

#Preview {
    SecondarySheetComponent(
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        selectedPatung: Patung(
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
