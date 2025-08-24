//
//  PatungDetailView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 19/08/25.
//

import SwiftUI
import MapKit

struct PatungDetailView: View {
    let patung: Patung
    
    @ObservedObject var patungViewModel: PatungViewModel
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    @State private var patungMedia: [PatungMedia] = []
    @State private var isLoadingMedia: Bool = false
    @State private var showFullscreenImage = false
    @State private var selectedPhoto: PatungMedia?
    @State var isOpeningMap: Bool = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 30) {
                PhotoScrollView(isLoadingMedia: $isLoadingMedia, media: patungMedia, showFullscreenImage: $showFullscreenImage, selectedPhoto: $selectedPhoto)
                
                ButtonCard(title: patung.name,
                           subtitle: patung.address ?? "No address",
                           icon: "car") {
                    isOpeningMap.toggle()
                }
                           .confirmationDialog("Where would you like to open the map?", isPresented: $isOpeningMap) {
                               Button {
                                   let coordinate = CLLocationCoordinate2D(latitude: Double(patung.latitude ?? 0), longitude: Double(patung.longitude ?? 0))
                                   let placemark = MKPlacemark(coordinate: coordinate)
                                   let mapItem = MKMapItem(placemark: placemark)
                                   mapItem.name = patung.name
                                   mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: coordinate])
                               } label: {
                                   Text("Open in Maps")
                               }
                               Button {
                                   let latitude = patung.latitude ?? 0
                                   let longitude = patung.longitude ?? 0
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
                
                VStack {
                    Text("About")
                        .font(Font.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(patung.buildReason ?? "No description")
                        .font(Font.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    DefaultCard(title: "Dimension", subtitle: patung.dimension)
                    DefaultCard(title: "Material", subtitle: patung.material)
                    
                    DefaultCard(title: "Weight", subtitle: nil)
                    DefaultCard(title: "Sculptor", subtitle: patung.artist)
                    
                    DefaultCard(title: "Construction", subtitle: "Build in \(patung.inaugurationYear ?? 1990)")
                    DefaultCard(title: "Structure", subtitle: nil)
                }
                
                
                if let story = patung.story {
                    VStack {
                        Text("Story Behind Patung")
                            .font(Font.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(patung.story ?? "No story available for this patung.")
                            .font(Font.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                    .frame(minHeight: 50)
            }
            .padding()
            
        }
        .navigationTitle(patung.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPatungMedia()
        }
        .fullScreenCover(item: $selectedPhoto) { _ in
            PhotoFullView(photo: $selectedPhoto)
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



//struct DetailCard: View {
//    let title: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .textCase(.uppercase)
//
//            Text(value)
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.leading)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
//    }
//}

struct ButtonCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(Font.callout.bold())
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(Font.subheadline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(Font.system(size: 26, weight: .bold))
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.secondary)
            .cornerRadius(20)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        
        
    }
}

struct DefaultCard: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.callout.bold())
            Text(subtitle ?? "-")
                .font(Font.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PatungDetailView(
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
        patungViewModel: PatungViewModel(),
        bookmarkPatungViewModel: BookmarkPatungViewModel()
    )
}
