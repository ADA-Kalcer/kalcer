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
    
    public static func coordinateInsideRegion(coordinate: CLLocationCoordinate2D, region: MKCoordinateRegion) -> Bool {
        let latMin = region.center.latitude - region.span.latitudeDelta
        let latMax = region.center.latitude + region.span.latitudeDelta
        let longMin = region.center.longitude - region.span.longitudeDelta
        let longMax = region.center.longitude + region.span.longitudeDelta
        
        return (coordinate.latitude >= latMin && coordinate.latitude <= latMax) &&
        (coordinate.longitude >= longMin && coordinate.longitude <= longMax)
    }
}
