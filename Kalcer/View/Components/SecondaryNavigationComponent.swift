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
    @Binding var cameraPosition: MapCameraPosition

    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                showTourModeConfirmation = true
                tourModeState.toggle()
            } label: {
                Image(systemName: "headphones")
                    .font(.title2)
                    .foregroundStyle(tourModeState ? .white : Color.rgb(red: 64, green: 64, blue: 1))
                    .padding()
            }
            .glassEffect(
                tourModeState ?
                    .regular.tint(.blue.opacity(0.8)).interactive() :
                        .regular.interactive()
            )
            
            Button {
                if coreLocationViewModel.authorizationStatus == .notDetermined {
                    coreLocationViewModel.locationManager.requestWhenInUseAuthorization()
                }
                coreLocationViewModel.locationManager.requestLocation()
                cameraPosition = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: coreLocationViewModel.latitude ?? 0,
                            longitude: coreLocationViewModel.longitude ?? 0
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
                locationState = true
            } label: {
                Image(systemName: locationState ? "location.fill" : "location")
                    .font(.title2)
                    .foregroundStyle(locationState ? .blue : Color.rgb(red: 64, green: 64, blue: 1))
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
        }
    }
}

#Preview {
    SecondaryNavigationComponent(
        coreLocationViewModel: CoreLocationViewModel(),
        locationState: .constant(true),
        tourModeState: .constant(true),
        showTourModeConfirmation: .constant(true),
        cameraPosition: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        ))
    )
}
