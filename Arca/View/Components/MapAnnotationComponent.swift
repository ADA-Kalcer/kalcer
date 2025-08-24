//
//  MapAnnotationComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 23/08/2025.
//

import SwiftUI

struct MapAnnotationComponent: View {
    @ObservedObject var recentPatungViewModel: RecentPatungViewModel
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    var patung: Patung
    @Binding var selectedPatung: Patung?
    @Binding var searchSheet: Bool
    
    var body: some View {
        Button {
            selectedPatung = patung
            recentPatungViewModel.addRecentPatung(patung)
            searchSheet = false
        } label: {
            ZStack {
                Circle()
                    .fill(
                        patung.id == selectedPatung?.id ?
                        Color.arcaPrimary :
                            bookmarkPatungViewModel.isBookmarked(patung) ?
                        Color.arcaDark :
                            Color.arcaSecondary
                    )
                    .stroke(Color.white, lineWidth: 2)
                
                if bookmarkPatungViewModel.isBookmarked(patung) {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.arcaLight)
                        .padding(8)
                } else {
                    Image(patung.category1 == "monumental" ? "monument" : "ritual")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(3)
                }
                
            }
        }
    }
}

#Preview {
    MapAnnotationComponent(
        recentPatungViewModel: RecentPatungViewModel(),
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        patung: Patung(
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
            category1: "monumental",
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
        ),
        selectedPatung: .constant(
            Patung(
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
                category1: "monumental",
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
        ),
        searchSheet: .constant(true)
    )
}
