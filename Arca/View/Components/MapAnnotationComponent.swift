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
    @Binding var sheetDetent: PresentationDetent
    
    var body: some View {
        let isSelected = patung.id == selectedPatung?.id
        let isMonument = patung.category1 == "monumental"
        let isRitual = patung.category1 == "ritual"
        let isBookmark = bookmarkPatungViewModel.isBookmarked(patung)
        
        ZStack {
            Circle()
                .fill(
                    annotationColor(isSelected: isSelected, isMonument: isMonument, isRitual: isRitual, isBookmark: isBookmark)
                )
                .stroke(Color.white, lineWidth: 3)
            
            if isBookmark {
                Image("bookmarkWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .padding(8)
            } else if isMonument {
                Image("monumentWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .padding(8)
            } else if isRitual {
                Image("ritualWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .padding(5)
            }
        }
        .onTapGesture {
            if selectedPatung != nil {
                selectedPatung = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedPatung = patung
                    recentPatungViewModel.addRecentPatung(patung)
                    searchSheet = false
                }
            } else {
                selectedPatung = patung
                recentPatungViewModel.addRecentPatung(patung)
                searchSheet = false
            }
            sheetDetent = .fraction(0.4)
        }
        .scaleEffect(isSelected ? 1.5 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6,
                           blendDuration: 0), value: isSelected)
    }
    
    private func annotationColor(isSelected: Bool, isMonument: Bool, isRitual: Bool, isBookmark: Bool) -> Color {
        if isSelected {
            if isBookmark {
                return Color.arcaGoldTinted
            }
            else if isMonument {
                return Color.arcaPrimaryTinted
            } else if isRitual {
                return Color.arcaSecondaryTinted
            }
        } else {
            if isBookmark {
                return Color.arcaGold
            }
            else if isMonument {
                return Color.arcaPrimary
            } else if isRitual {
                return Color.arcaSecondary
            }
        }
        
        return .clear
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
            audioURL: nil,
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
                audioURL: nil,
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
        searchSheet: .constant(true),
        sheetDetent: .constant(.medium)
    )
}
