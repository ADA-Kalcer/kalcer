//
//  SecondaryNavigationComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 22/08/2025.
//

import SwiftUI
import MapKit

struct SecondaryNavigationComponent: View {
    @ObservedObject var coreLocationViewModel: CoreLocationViewModel
    @Binding var locationState: Bool
    @Binding var tourModeState: Bool
    @Binding var showTourModeConfirmation: Bool
    @Binding var searchSheetDetent: PresentationDetent
    @Binding var cameraPosition: MapCameraPosition
    
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                showTourModeConfirmation = true
                tourModeState.toggle()
            } label: {
                Image(systemName: "headphones")
                    .font(.title2)
                    .foregroundStyle(tourModeState ? .white : .arcaDark)
                    .padding()
            }
            .glassEffect(
                tourModeState ?
                    .regular.tint(.arcaPrimary.opacity(0.8)).interactive() :
                        .regular.interactive()
            )
            
            Button {
                if coreLocationViewModel.authorizationStatus == .notDetermined {
                    coreLocationViewModel.locationManager.requestWhenInUseAuthorization()
                }
                coreLocationViewModel.locationManager.requestLocation()
                locationState = true
                withAnimation {
                    cameraPosition = MapCameraPosition.region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: (coreLocationViewModel.latitude ?? 0) - (searchSheetDetent == .fraction(0.4) ? 0.004 : 0),
                                longitude: coreLocationViewModel.longitude ?? 0
                            ),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            } label: {
                Image(systemName: locationState ? "location.fill" : "location")
                    .font(.title2)
                    .foregroundStyle(locationState ? .arcaPrimary : .arcaDark)
                    .padding()
            }
            .glassEffect(.regular.interactive())
            .onChange(of: cameraPosition) { _, newValue in
                if coreLocationViewModel.latitude != newValue.region?.center.latitude ||
                    coreLocationViewModel.longitude != newValue.region?.center.longitude
                {
                    locationState = false
                }
            }
            .onChange(of: coreLocationViewModel.latitude) {
                if locationState {
                    withAnimation {
                        cameraPosition = MapCameraPosition.region(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(
                                    latitude: (coreLocationViewModel.latitude ?? 0) - (searchSheetDetent == .fraction(0.4) ? 0.004 : 0),
                                    longitude: coreLocationViewModel.longitude ?? 0
                                ),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    SecondaryNavigationComponent(
        coreLocationViewModel: CoreLocationViewModel(),
        locationState: .constant(true),
        tourModeState: .constant(true),
        showTourModeConfirmation: .constant(true),
        searchSheetDetent: .constant(.medium),
        cameraPosition: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        ))
    )
}
