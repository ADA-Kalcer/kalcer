//
//  UpdateMapCamera.swift
//  Kalcer
//
//  Created by Tude Maha on 22/08/2025.
//

import Foundation
import _MapKit_SwiftUI

struct MapUtils {
    public static func zoomMapCamera(latitude: Double, longitude: Double) -> MapCameraPosition {
        return MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        )
    }
}
