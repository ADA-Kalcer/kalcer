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
    @StateObject private var recentPatungViewModel = RecentPatungViewModel()
    @StateObject private var coreLocationViewModel = CoreLocationViewModel()
    
    @State private var searchQuery = ""
    @State private var searchSheet = false
    @State private var detailSheet = false
    @State private var tourModeState = false
    @State private var currentLocationState = false
    @State private var recentSheet = false
    @State private var recentSource: RecentSource = .search
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
                                MapAnnotationComponent(patung: patung, selectedPatung: $selectedPatung, searchSheet: $searchSheet)
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
                
                if !patungViewModel.isLoading || selection != .large {
                    SecondaryNavigationComponent(
                        tourModeState: $tourModeState,
                        locationState: $currentLocationState
                    )
                    .position(
                        x: 350,
                        y: 575 - (selection == .fraction(0.4) ? 250 : 0)
                    )
                }
                
                if patungViewModel.isLoading {
                    ProgressModalComponent()
                } else {
                    if patungViewModel.isError != nil {
                        SupabaseErrorComponent(
                            patungViewModel: patungViewModel,
                            searchSheet: $searchSheet
                        )
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
            SearchSheetComponent(
                sheetPresentation: $selection,
                selectedPatung: $selectedPatung,
                searchSheet: $searchSheet,
                recentSheet: $recentSheet,
                recentSource: $recentSource,
                cameraPosition: $position
            )
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
        .sheet(isPresented: $recentSheet) {
            NavigationView {
                RecentListView(recentSource: $recentSource, selectedPatung: $selectedPatung)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                recentSheet = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
            
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled(true)
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
