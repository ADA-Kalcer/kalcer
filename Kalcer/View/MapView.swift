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
    @StateObject private var coreLocationViewModel = CoreLocationViewModel()
    
    @State private var searchQuery = ""
    @State private var searchSheet = false
    @State private var detailSheet = false
    @State private var selectedPatung: Patung?
    @State private var selection: PresentationDetent = .height(80)
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
            span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
        )
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    if !patungViewModel.isLoading {
                        ForEach(patungViewModel.patungs) { patung in
                            Annotation(patung.name, coordinate: CLLocationCoordinate2D(latitude: Double(patung.latitude ?? 0.0), longitude: Double(patung.longitude ?? 0.0))) {
                                Button {
                                    selectedPatung = patung
                                    searchSheet = false
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(patung.id == selectedPatung?.id ? Color.red : Color.yellow)
                                            .stroke(Color.white, lineWidth: 2)
                                        Text("🗿")
                                            .padding(5)
                                    }
                                }
                            }
                        }
                    }
                    
                    UserAnnotation()
                }
                .onChange(of: coreLocationViewModel.latitude) {
                    position = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: coreLocationViewModel.latitude ?? 0,
                                longitude: coreLocationViewModel.longitude ?? 0
                            ),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
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
            SearchSheetComponent(sheetPresentation: $selection, selectedPatung: $selectedPatung, searchSheet: $searchSheet)
                .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
        }
        .sheet(item: $selectedPatung) { patung in
            NavigationView {
                PatungDetailView(patung: patung)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                selectedPatung = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .onAppear {
                searchSheet = false
            }
            .onDisappear {
                searchSheet = true
            }
        }
    }
}

#Preview {
    MapView()
}
