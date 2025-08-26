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
    
    @State private var patungPresentationQueue: [Patung] = []
    
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
        .sheet(item: $activeSheet) { sheet in
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
        // 3. REPLACE your old onChange modifiers with these two.
        .onChange(of: selectedPatung) { _, patung in
            // This rule is simple: if a patung is selected, we MUST show the detail sheet.
            if patung != nil {
                activeSheet = .patungDetail
            }
        }
        .onChange(of: activeSheet) { oldValue, newValue in
            // This is the cleanup and state synchronization logic.
            if oldValue == .patungDetail && newValue != .patungDetail {
                // The selection must be cleared when navigating away from the detail sheet.
                selectedPatung = nil
                
                // After cleaning up, immediately try to present the next item in the queue.
                presentNextPatungInQueue()
            }

            // RULE: If the detail sheet was dismissed by a swipe (newValue is nil),
            // then we should return to the search sheet.
            if oldValue == .patungDetail && newValue == nil {
                activeSheet = .search
            }
        }
    }
    
    private func handleLocationUpdate() {
        guard tourModeState,
              let userLatitude = coreLocationViewModel.latitude,
              let userLongitude = coreLocationViewModel.longitude else { return }

        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)

        // --- LOGIC TO CLOSE SHEET (remains the same) ---
        if activeSheet == .patungDetail,
           let currentPatung = selectedPatung,
           let patungLatitude = currentPatung.latitude,
           let patungLongitude = currentPatung.longitude {
            
            let patungLocation = CLLocation(latitude: Double(patungLatitude), longitude: Double(patungLongitude))
            
            if userLocation.distance(from: patungLocation) > 50 {
                activeSheet = .search
                return // Exit early
            }
        }

        // --- LOGIC TO POPULATE QUEUE ---
        // Find all patungs within the 50-meter radius
        let nearbyPatungs = patungViewModel.patungs.filter { patung in
            guard let lat = patung.latitude, let lon = patung.longitude else { return false }
            let patungLocation = CLLocation(latitude: Double(lat), longitude: Double(lon))
            // Ensure it's not the currently selected one
            return userLocation.distance(from: patungLocation) <= 50 && patung.id != selectedPatung?.id
        }

        // Add new nearby patungs to the queue if they aren't already in it
        for patung in nearbyPatungs {
            if !patungPresentationQueue.contains(where: { $0.id == patung.id }) {
                patungPresentationQueue.append(patung)
            }
        }

        // --- ATTEMPT TO PRESENT FROM QUEUE ---
        presentNextPatungInQueue()
    }

    private func presentNextPatungInQueue() {
        // Only present if no detail sheet is currently active and the queue is not empty
        if activeSheet != .patungDetail, !patungPresentationQueue.isEmpty {
            // Dequeue the next patung and select it
            selectedPatung = patungPresentationQueue.removeFirst()
        }
    }

}

#Preview {
    MapView()
}
