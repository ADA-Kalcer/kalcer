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
    @StateObject private var recentSearchViewModel = RecentSearchViewModel()
    @StateObject private var coreLocationViewModel = CoreLocationViewModel()
    @StateObject private var bookmarkPatungViewModel = BookmarkPatungViewModel()
    
    @AppStorage("tourMode") var tourModeShowAgain: Bool = true
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var searchQuery = ""
    @State private var searchSheet = false
    @State private var detailSheet = false
    @State private var tourModeState = false
    @State private var showTourConfirmation = false
    @State private var currentLocationState = false
    @State private var recentSheet = false
    @State private var recentSource: RecentSource = .search
    @State private var bookmarkSheet = false
    @State private var selectedPatung: Patung?
    @State private var selection: PresentationDetent = .height(80)
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
            span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
        )
    )
    
    @State private var proximityTriggeredPatungId: UUID?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    if !patungViewModel.isLoading {
                        ForEach(patungViewModel.patungs) { patung in
                            Annotation(patung.name, coordinate: CLLocationCoordinate2D(latitude: Double(patung.latitude ?? 0.0), longitude: Double(patung.longitude ?? 0.0))) {
                                MapAnnotationComponent(
                                    recentPatungViewModel: recentPatungViewModel,
                                    bookmarkPatungViewModel: bookmarkPatungViewModel,
                                    patung: patung,
                                    selectedPatung: $selectedPatung,
                                    searchSheet: $searchSheet)
                            }
                        }
                    }
                    
                    UserAnnotation()
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
                
                if !patungViewModel.isLoading || selection != .large {
                    SecondaryNavigationComponent(
                        coreLocationViewModel: coreLocationViewModel,
                        locationState: $currentLocationState,
                        tourModeState: $tourModeState,
                        showTourModeConfirmation: $showTourConfirmation,
                        cameraPosition: $position
                    )
                    .position(
                        x: 350,
                        y: 575 - (selection == .fraction(0.4) ? 250 : 0)
                    )
                }
                
                if tourModeShowAgain && showTourConfirmation && tourModeState {
                    TourModeConfirmationComponent(
                        showConfirmation: $showTourConfirmation,
                        tourModeState: $tourModeState,
                        tourModeShowAgain: $tourModeShowAgain
                    )
                    .onAppear {
                        searchSheet = false
                    }
                    .onDisappear {
                        searchSheet = true
                    }
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
            .onChange(of: tourModeState) { _, isEnabled in
                if isEnabled {
                    coreLocationViewModel.startUpdatingLocation()
                } else {
                    coreLocationViewModel.stopUpdatingLocation()
                }
            }
            .onChange(of: coreLocationViewModel.longitude) {
                handleLocationUpdate()
            }
        }
        .onAppear {
            Task {
                try await patungViewModel.getPatungs()
                // Set the initial sheet to be the search sheet
                activeSheet = .search
            }
        }
        // Replace ALL of your existing .sheet modifiers with this single one
        .sheet(item: $activeSheet, onDismiss: {
            // This onDismiss handles the swipe-down gesture.
            // If the sheet is dismissed to nil, and it wasn't the search sheet,
            // we want to bring the search sheet back.
            if activeSheet == nil {
                activeSheet = .search
            }
        }) { sheet in
            switch sheet {
            case .search:
                SearchSheetComponent(
                    patungViewModel: patungViewModel,
                    recentPatungViewModel: recentPatungViewModel,
                    recentSearchViewModel: recentSearchViewModel,
                    bookmarkPatungViewModel: bookmarkPatungViewModel,
                    sheetPresentation: $selection,
                    selectedPatung: $selectedPatung,
                    searchSheet: Binding(
                        get: { self.activeSheet == .search },
                        set: { if !$0 { self.activeSheet = nil } }
                    ),
                    recentSheet: Binding(
                        get: { self.activeSheet == .recent },
                        set: { if $0 { self.activeSheet = .recent } }
                    ),
                    recentSource: $recentSource,
                    cameraPosition: $position,
                    bookmarkSheet: Binding(
                        get: { self.activeSheet == .bookmark },
                        set: { if $0 { self.activeSheet = .bookmark } }
                    )
                )
                .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
            case .patungDetail:
                if let patung = selectedPatung {
                    NavigationView {
                        ZStack {
                            PatungDetailView(
                                patung: patung,
                                patungViewModel: patungViewModel,
                                bookmarkPatungViewModel: bookmarkPatungViewModel
                            )
                            
                            VStack {
                                Spacer()
                                SecondarySheetComponent(
                                    bookmarkPatungViewModel: bookmarkPatungViewModel,
                                    selectedPatung: patung
                                )
                                    .padding(.bottom, 10)
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    // 1. Explicitly return to the search sheet
                                    activeSheet = .search
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            case .recent:
                NavigationView {
                    RecentListView(
                        recentPatungViewModel: recentPatungViewModel,
                        recentSearchViewModel: recentSearchViewModel,
                        recentSource: $recentSource,
                        selectedPatung: $selectedPatung
                    )
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    activeSheet = .search // Go back to search
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            case .bookmark:
                NavigationView {
                    BookmarkListView(
                        bookmarkPatungViewModel: bookmarkPatungViewModel,
                        selectedPatung: $selectedPatung
                    )
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    activeSheet = .search // Go back to search
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: selectedPatung) { _, newValue in
            if newValue != nil {
                activeSheet = .patungDetail
            } else {
                // 2. When selection is cleared, ensure we return to the search sheet
                if activeSheet == .patungDetail {
                    activeSheet = .search
                }
            }
        }
    }
    
    private func handleLocationUpdate() {
            // Ensure Tour Mode is active and we have a user location
            guard tourModeState,
                  let userLatitude = coreLocationViewModel.latitude,
                  let userLongitude = coreLocationViewModel.longitude else { return }

            let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)

            // Reset the proximity trigger if the user has moved more than 100 meters away from the last shown patung
            if let triggeredId = proximityTriggeredPatungId,
               let lastShownPatung = patungViewModel.patungs.first(where: { $0.id == triggeredId }),
               let lat = lastShownPatung.latitude, let lon = lastShownPatung.longitude {
                let patungLocation = CLLocation(latitude: Double(lat), longitude: Double(lon))
                if userLocation.distance(from: patungLocation) > 100 {
                    proximityTriggeredPatungId = nil
                }
            }
            
            // Don't show a new sheet if one is already presented
            guard selectedPatung == nil else { return }

            // Find the closest patung within 50 meters
            for patung in patungViewModel.patungs {
                guard let patungLatitude = patung.latitude,
                      let patungLongitude = patung.longitude else { continue }
                
                // Ensure this patung hasn't been triggered recently
                if patung.id == proximityTriggeredPatungId { continue }

                let patungLocation = CLLocation(latitude: Double(patungLatitude), longitude: Double(patungLongitude))
                let distance = userLocation.distance(from: patungLocation)

                // If within 50 meters, select the patung and break the loop
                if distance <= 50 {
                    selectedPatung = patung
                    proximityTriggeredPatungId = patung.id
                    break
                }
            }
        }
    
}

#Preview {
    MapView()
}
