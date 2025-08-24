//
//  BookmarkListView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import SwiftUI
import MapKit

struct BookmarkListView: View {
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    @Binding var selectedPatung: Patung?
    @Binding var bookmarkSheet: Bool
    @Binding var afterDetailDismiss: Sheet
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    ForEach(bookmarkPatungViewModel.bookmarkPatungs) { patung in
                        SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address", icon: "bookmark", withSuffix: false)
                            .onTapGesture {
                                bookmarkSheet = false
                                afterDetailDismiss = .bookmark
                                selectedPatung = patung
                                cameraPosition = MapUtils.zoomMapCamera(
                                    latitude: Double(selectedPatung?.latitude ?? 0),
                                    longitude: Double(selectedPatung?.longitude ?? 0)
                                )
                            }
                    }
                    .onDelete(perform: deleteBookmark)
                }
                .frame(height: CGFloat(min(bookmarkPatungViewModel.bookmarkPatungs.count, 5) * 70))
                .cornerRadius(20)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
        }
        .navigationTitle("Bookmark")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func deleteBookmark(at offsets: IndexSet) {
        bookmarkPatungViewModel.removeBookmarkPatungByOffset(at: offsets)
        
    }
}

#Preview {
    BookmarkListView(
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        selectedPatung: .constant(nil),
        bookmarkSheet: .constant(false),
        afterDetailDismiss: .constant(.bookmark),
        cameraPosition: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        ))
    )
}
