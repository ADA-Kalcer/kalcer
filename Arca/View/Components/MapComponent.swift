//
//  MapComponent.swift
//  Arca
//
//  Created by Tude Maha on 28/08/2025.
//

import SwiftUI
import MapKit

struct MapComponent: View {
    @ObservedObject var patungViewModel: PatungViewModel
    @ObservedObject var recentPatungViewModel: RecentPatungViewModel
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    let egg1Region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.72, longitude: 115.36),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.04)
    )
    let egg2Region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.55, longitude: 114.87),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.04)
    )
    @State private var egg1State = false
    @State private var egg2State = false
    
    @Binding var position: MapCameraPosition
    @Binding var selectedPatung: Patung?
    @Binding var selection: PresentationDetent
    @Binding var searchSheet: Bool
    
    var iosLiquid: Bool
    
    var body: some View {
        Map(position: $position) {
            if !patungViewModel.isLoading {
                ForEach(patungViewModel.patungs) { patung in
                    Annotation(patung.name, coordinate: CLLocationCoordinate2D(latitude: Double(patung.latitude ?? 0.0), longitude: Double(patung.longitude ?? 0.0))) {
                        MapAnnotationComponent(
                            recentPatungViewModel: recentPatungViewModel,
                            bookmarkPatungViewModel: bookmarkPatungViewModel,
                            patung: patung,
                            selectedPatung: $selectedPatung,
                            searchSheet: $searchSheet,
                            sheetDetent: $selection
                        )
                    }
                }
                
                if egg1State {
                    Annotation("Naga Antaboga", coordinate: CLLocationCoordinate2D(
                        latitude: egg1Region.center.latitude,
                        longitude: egg1Region.center.longitude
                    )) {
                        Image("antaboga")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                }
                
                if egg2State {
                    Annotation("Gajah Mina", coordinate: CLLocationCoordinate2D(
                        latitude: egg2Region.center.latitude,
                        longitude: egg2Region.center.longitude
                    )) {
                        Image("gajahMina")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                }
            }
            
            UserAnnotation()
            
            // Enable to add user annotation radius
            //                    if let latitude = coreLocationViewModel.latitude,
            //                       let longitude = coreLocationViewModel.longitude {
            //                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            //                        MapCircle(center: coordinate, radius: radiusInMeters)
            //                            .foregroundStyle(.blue.opacity(0.2))
            //                    }
        }
        .safeAreaInset(edge: .bottom) {
            EmptyView()
                .frame(height: iosLiquid ? 60 : 80)
        }
        .safeAreaInset(edge: .leading) {
            EmptyView()
                .frame(width: 8)
        }
        .onMapCameraChange { mapCamera in
            let cameraCenter = mapCamera.region.center
            egg1State = MapUtils.coordinateInsideRegion(coordinate: cameraCenter, region: egg1Region)
            egg2State = MapUtils.coordinateInsideRegion(coordinate: cameraCenter, region: egg2Region)
        }
        // turn it on if you want to change the camera position on app start and detect location changes
        //                .onChange(of: coreLocationViewModel.latitude) {
        //                    position = .region(
        //                        MKCoordinateRegion(
        //                            center: CLLocationCoordinate2D(
        //                                latitude: coreLocationViewModel.latitude ?? 0,
        //                                longitude: coreLocationViewModel.longitude ?? 0
        //                            ),
        //                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        //                        )
        //                    )
        //                }
        
    }
}

#Preview {
    MapComponent(
        patungViewModel: PatungViewModel(),
        recentPatungViewModel: RecentPatungViewModel(),
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        position: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        )),
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
        selection: .constant(.medium),
        searchSheet: .constant(true),
        iosLiquid: true
    )
}
