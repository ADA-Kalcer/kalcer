//
//  ContentView.swift
//  Kalcer
//
//  Created by Tude Maha on 15/08/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var patungViewModel = PatungViewModel()
    
    @State private var searchQuery = ""
    @State private var searchSheet = false
    @State private var selection: PresentationDetent = .height(80)
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -8.5, longitude: 115.18),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    if !patungViewModel.isLoading {
                        ForEach(patungViewModel.patungs) { patung in
                            Annotation(patung.name, coordinate: CLLocationCoordinate2D(latitude: Double(patung.latitude ?? 0.0), longitude: Double(patung.longitude ?? 0.0))) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .stroke(Color.white, lineWidth: 2)
                                    Text("🗿")
                                        .padding(5)
                                }
                            }
                        }
                    }
                }
                
                if patungViewModel.isLoading {
                    ProgressView("Loading patungs...")
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.7))
                } else {
                    if patungViewModel.isError != nil {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.icloud")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            Text("Something went wrong!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(patungViewModel.isError?.description ??
                                 "Unknown error occurred")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                Task {
                                    try await patungViewModel.getPatungs()
                                    searchSheet = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .onAppear {
                            searchSheet = false
                        }
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            Task {
                try await patungViewModel.getPatungs()
                searchSheet = true
            }
        }
        .sheet(isPresented: $searchSheet) {
            SearchSheetComponent(sheetPresentation: $selection)
                .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    MapView()
}
