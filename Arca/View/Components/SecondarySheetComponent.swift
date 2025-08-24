//
//  SecondarySheetComponent.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import SwiftUI
import MapKit

struct SecondarySheetComponent: View {
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    @State var isOpeningMap: Bool = false
    let selectedPatung: Patung
    
    var body: some View {
        HStack {
            Button {
                bookmarkPatungViewModel.toggleBookmark(selectedPatung)
            } label: {
                Image(systemName: bookmarkPatungViewModel.isBookmarked(selectedPatung) ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .foregroundStyle(.arcaDark)
                    .padding()
            }
            
            Button {
                isOpeningMap.toggle()
            } label: {
                Image(systemName: "car")
                    .font(.title2)
                    .foregroundStyle(.arcaDark)
                    .padding()
            }
            .confirmationDialog("Where would you like to open the map?", isPresented: $isOpeningMap) {
                Button {
                    let coordinate = CLLocationCoordinate2D(latitude: Double(selectedPatung.latitude ?? 0), longitude: Double(selectedPatung.longitude ?? 0))
                    let placemark = MKPlacemark(coordinate: coordinate)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = selectedPatung.name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: coordinate])
                } label: {
                    Text("Open in Maps")
                }
                Button {
                    let latitude = selectedPatung.latitude ?? 0
                    let longitude = selectedPatung.longitude ?? 0
                    let googleMapsURL =
                    "comgooglemaps://?q=\(latitude),\(longitude)"
                    if let url = URL(string: googleMapsURL),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        let webURL = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
                        if let url = URL(string: webURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                } label: {
                    Text("Open in Google Maps")
                }
            }
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
    )
}
