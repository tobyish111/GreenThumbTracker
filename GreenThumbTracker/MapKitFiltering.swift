//
//  MapKitFiltering.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/21/25.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
    
    /// Rounds both latitude and longitude to a specified number of decimal places.
    func rounded(to decimals: Int) -> CLLocationCoordinate2D {
        let factor = pow(10.0, Double(decimals))
        let roundedLat = (latitude * factor).rounded() / factor
        let roundedLon = (longitude * factor).rounded() / factor
        return CLLocationCoordinate2D(latitude: roundedLat, longitude: roundedLon)
    }
    
    /// Clamps latitude and longitude to their legal bounds: [-90, 90] for lat and [-180, 180] for lon.
    var clamped: CLLocationCoordinate2D {
        let clampedLat = max(-90.0, min(90.0, latitude))
        let clampedLon = max(-180.0, min(180.0, longitude))
        return CLLocationCoordinate2D(latitude: clampedLat, longitude: clampedLon)
    }

    /// Combines rounding and clamping: rounds first, then clamps the values to safe MapKit limits.
    func safeForMapKit(precision decimals: Int = 6) -> CLLocationCoordinate2D {
        return self.rounded(to: decimals).clamped
    }
    
    var isValidForMapKit: Bool {
        CLLocationCoordinate2DIsValid(self) &&
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }
}
