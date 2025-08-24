//
//  RecentListView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 22/08/25.
//

import SwiftUI
import MapKit

struct RecentListView: View {
    @ObservedObject var recentPatungViewModel: RecentPatungViewModel
    @ObservedObject var recentSearchViewModel: RecentSearchViewModel
    
    @Binding var recentSource: RecentSource
    @Binding var selectedPatung: Patung?
    @Binding var recentSheet: Bool
    @Binding var afterDetailDismiss: Sheet
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    ForEach(recentSource == .annotate ? recentPatungViewModel.recentPatungs : recentSearchViewModel.recentSearch) { patung in
                        SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address", withSuffix: false)
                            .onTapGesture {
                                recentSheet = false
                                afterDetailDismiss = .recent
                                selectedPatung = patung
                                cameraPosition = MapUtils.zoomMapCamera(
                                    latitude: Double(selectedPatung?.latitude ?? 0),
                                    longitude: Double(selectedPatung?.longitude ?? 0)
                                )
                            }
                    }
                    .onDelete(perform: deleteRecent)
                }
                .frame(height: CGFloat(min(recentSource == .annotate ? recentPatungViewModel.recentPatungs.count : recentSearchViewModel.recentSearch.count, 5) * 70))
                .cornerRadius(20)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
        }
        .navigationTitle("Recent")
        .navigationBarTitleDisplayMode(.large)
        
        
    }
    
    private func deleteRecent(at offsets: IndexSet) {
        switch recentSource {
        case .annotate:
            recentPatungViewModel.removeRecentPatungByOffset(at: offsets)
        case .search:
            recentSearchViewModel.removeRecentSearchByOffset(at: offsets)
        }
        
    }
}

#Preview {
    RecentListView(
        recentPatungViewModel: RecentPatungViewModel(),
        recentSearchViewModel: RecentSearchViewModel(),
        recentSource: .constant(.annotate),
        selectedPatung: .constant(nil),
        recentSheet: .constant(false),
        afterDetailDismiss: .constant(.recent),
        cameraPosition: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        )),
    )
}
