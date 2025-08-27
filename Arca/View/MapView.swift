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
    @StateObject private var audioViewModel: AudioViewModel = AudioViewModel()
    
    @AppStorage("tourMode") var tourModeShowAgain: Bool = true
    
    @State private var searchQuery = ""
    @State private var searchSheet = false
    @State private var detailSheet = false
    @State private var tourModeState = false
    @State private var showTourConfirmation = false
    @State private var currentLocationState = false
    @State private var recentSheet = false
    @State private var recentSource: RecentSource = .search
    @State private var bookmarkSheet = false
    @State private var afterDetailDismiss: Sheet = .search
    @State private var selectedPatung: Patung?
    @State private var selection: PresentationDetent = .fraction(0.4)
    @State private var patungTourQueue: [Patung] = []
    @State private var currentTourPatung: Patung? = nil
    @State private var isPlayingTourAudio = false
    @State private var playedPatungs: Set<UUID> = []
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -9, longitude: 115.1),
            span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
        )
    )
    
    let radiusInMeters: CLLocationDistance = 50
    
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
                                    searchSheet: $searchSheet,
                                    sheetDetent: $selection
                                )
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
                        .frame(height: 60)
                }
                .safeAreaInset(edge: .leading) {
                    EmptyView()
                        .frame(width: 8)
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
                
                if !patungViewModel.isLoading || (selectedPatung == nil && selection != .large) {
                    GeometryReader { geo in
                        HStack {
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                SecondaryNavigationComponent(
                                    coreLocationViewModel: coreLocationViewModel,
                                    locationState: $currentLocationState,
                                    tourModeState: $tourModeState,
                                    showTourModeConfirmation: $showTourConfirmation,
                                    searchSheetDetent: $selection,
                                    cameraPosition: $position
                                )
                            }
                            .padding(.bottom, geo.size.height * ( selection == .height(80) ? 0.12 : 0.46))
                        }
                        .padding(.trailing, geo.size.width * 0.06)
                    }
                    
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
                    coreLocationViewModel.startUdatingLocation()
                } else {
                    coreLocationViewModel.stopUpdatingLocation()
                    
                    if isPlayingTourAudio {
                        audioViewModel.stopAudio()
                        isPlayingTourAudio = false
                    }
                    
                    currentTourPatung = nil
                    patungTourQueue.removeAll()
                    playedPatungs.removeAll()
                }
            }
            .onChange(of: coreLocationViewModel.longitude) { _, _ in
                handleLocationUpdate()
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
                patungViewModel: patungViewModel,
                recentPatungViewModel: recentPatungViewModel,
                recentSearchViewModel: recentSearchViewModel,
                bookmarkPatungViewModel: bookmarkPatungViewModel,
                sheetPresentation: $selection,
                selectedPatung: $selectedPatung,
                searchSheet: $searchSheet,
                recentSheet: $recentSheet,
                recentSource: $recentSource,
                cameraPosition: $position,
                bookmarkSheet: $bookmarkSheet
            )
            .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled(true)
        }
        .onChange(of: selectedPatung) { oldValue, newValue in
              if newValue != nil {
                  selection = .fraction(0.4)
              }
          }
        .sheet(item: $selectedPatung) { patung in
            NavigationView {
                ZStack {
                    PatungDetailView(
                        patung: patung,
                        patungViewModel: patungViewModel,
                        bookmarkPatungViewModel: bookmarkPatungViewModel,
                    )
                    
                    if selection != .height(80) {
                        VStack {
                            Spacer()
                            SecondarySheetComponent(
                                bookmarkPatungViewModel: bookmarkPatungViewModel,
                                selectedPatung: patung
                            )
                            .padding(.bottom, 10)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            selectedPatung = nil
                            DispatchQueue.main.async {
                                selection = .fraction(0.4)
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onAppear {
                    searchSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selection = .fraction(0.4)
                    }
                }
                .onDisappear {
                    if let currentTour = currentTourPatung, currentTour.id == selectedPatung?.id {
                        currentTourPatung = nil
                        
                        // Process next in queue after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.processNextPatungInQueue()
                        }
                    }
                    
                    switch afterDetailDismiss {
                    case .search:
                        searchSheet = true
                        break
                    case .recent:
                        recentSheet = true
                        afterDetailDismiss = .search
                        break
                    case .bookmark:
                        bookmarkSheet = true
                        afterDetailDismiss = .search
                        break
                    default:
                        break
                    }
                }
            }
            .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $recentSheet) {
            NavigationView {
                RecentListView(
                    recentPatungViewModel: recentPatungViewModel,
                    recentSearchViewModel: recentSearchViewModel,
                    recentSource: $recentSource,
                    selectedPatung: $selectedPatung,
                    recentSheet: $recentSheet,
                    afterDetailDismiss: $afterDetailDismiss,
                    cameraPosition: $position
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            recentSheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onAppear {
                    searchSheet = false
                }
                .onDisappear {
                    if selectedPatung == nil {
                        searchSheet = true
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $bookmarkSheet) {
            NavigationView {
                BookmarkListView(
                    bookmarkPatungViewModel: bookmarkPatungViewModel,
                    selectedPatung: $selectedPatung,
                    bookmarkSheet: $bookmarkSheet,
                    afterDetailDismiss: $afterDetailDismiss,
                    cameraPosition: $position
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            bookmarkSheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onAppear {
                    searchSheet = false
                }
                .onDisappear {
                    if selectedPatung == nil {
                        searchSheet = true
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled)
        }
    }
    
    private func handleLocationUpdate() {
        guard tourModeState,
              let currentLatitude = coreLocationViewModel.latitude,
              let currentLongitude = coreLocationViewModel.longitude else { return }
        
        print("User location: (lat: \(currentLatitude), long: \(currentLongitude))")
        
        let userLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        
        if let currentTour = currentTourPatung {
            let patungLocation = CLLocation(
                latitude: Double(currentTour.latitude ?? 0),
                longitude: Double(currentTour.longitude ?? 0)
            )
            
            if userLocation.distance(from: patungLocation) > radiusInMeters {
                print("User moved away from tour patung: \(currentTour.name)")
                
                // Close current detail sheet and move to next in queue
                selectedPatung = nil
                currentTourPatung = nil
                searchSheet = true
                
            }
        }
        
        if let selected = selectedPatung, currentTourPatung == nil {
            let patungLatitude = selected.latitude
            let patungLongitude = selected.longitude
            let patungLocation = CLLocation(latitude: Double(patungLatitude ?? 0), longitude: Double(patungLongitude ?? 0))
            
            if userLocation.distance(from: patungLocation) > radiusInMeters {
                print("User moved away from selected patung")
                
                self.selectedPatung = nil
                self.currentTourPatung = nil
                self.searchSheet = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.processNextPatungInQueue()
                }
            }
        }
        
        let nearbyPatungs = patungViewModel.patungs.filter { patung in
            guard let lat = patung.latitude, let lon = patung.longitude else { return false }
            let patungLocation = CLLocation(latitude: Double(lat), longitude: Double(lon))
            
            let isNearby = userLocation.distance(from: patungLocation) <= radiusInMeters
            let notCurrentlySelected = patung.id != selectedPatung?.id
            let notCurrentTour = patung.id != currentTourPatung?.id
            let notInQueue = !patungTourQueue.contains(where: { $0.id == patung.id })
            let notAlreadyPlayed = !playedPatungs.contains(patung.id)
            
            return isNearby && notCurrentlySelected && notCurrentTour && notInQueue && notAlreadyPlayed
        }
        
        for patung in nearbyPatungs {
            print("Adding patung to tour queue: \(patung.name)")
            patungTourQueue.append(patung)
        }
        
        let patungsToRemoveFromPlayed = playedPatungs.filter { playedId in
            guard let playedPatung = patungViewModel.patungs.first(where: { $0.id == playedId }),
                  let lat = playedPatung.latitude, let lon = playedPatung.longitude else { return true }
            let patungLocation = CLLocation(latitude: Double(lat), longitude: Double(lon))
            let distance = userLocation.distance(from: patungLocation)
            return distance > radiusInMeters
        }
        
        for patungId in patungsToRemoveFromPlayed {
            playedPatungs.remove(patungId)
            print("Cleared played status for patung (user moved away)")
        }
        
        if currentTourPatung == nil && selectedPatung == nil {
            processNextPatungInQueue()
        }
    }
    
    private func processNextPatungInQueue() {
        guard !patungTourQueue.isEmpty else { return }
        
        let nextPatung = patungTourQueue.removeFirst()
        print("Auto-presenting patung from queue: \(nextPatung.name)")
        
        // Set as current tour patung and present detail sheet
        if selectedPatung != nil {
            selectedPatung = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.currentTourPatung = nextPatung
                self.selectedPatung = nextPatung
                self.searchSheet = false
                self.selection = .fraction(0.4)
            }
        } else {
            currentTourPatung = nextPatung
            selectedPatung = nextPatung
            searchSheet = false
            
            if let audioURL = nextPatung.audioURL, !audioURL.isEmpty {
                if isPlayingTourAudio {
                    audioViewModel.stopAudio()
                }
                
                playedPatungs.insert(nextPatung.id)
                
                isPlayingTourAudio = true
                audioViewModel.playAudio(from: audioURL) {
                    DispatchQueue.main.async {
                        self.isPlayingTourAudio = false
                        self.selectedPatung = nil
                        self.currentTourPatung = nil
                        self.searchSheet = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.processNextPatungInQueue()
                        }
                    }
                }
            } else {
                playedPatungs.insert(nextPatung.id)
            }
            
            DispatchQueue.main.async {
                self.selection = .fraction(0.4)
            }
        }
    }

}

#Preview {
    MapView()
}
