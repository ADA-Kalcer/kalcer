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
//        adjustment values needed if the safe area of the map changed
        return MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude - 0.0025, longitude: longitude + 0.0003),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        )
    }
}
