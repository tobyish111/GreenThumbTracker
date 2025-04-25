//
//  GeoJSONLoader.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import Foundation
import MapKit
import UIKit

class GeoJSONLoader {
    static func loadOverlay(for tdwgCode: String) -> [MKOverlay]? {
        guard let url = Bundle.main.url(forResource: tdwgCode, withExtension: "geojson", subdirectory: "GeoJSONData") else {
            print("❌ GeoJSON for \(tdwgCode) not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let features = try MKGeoJSONDecoder().decode(data)
            return features.compactMap { $0 as? MKOverlay }
        } catch {
            print("❌ Error loading GeoJSON for \(tdwgCode): \(error)")
            return nil
        }
    }
}


//MARK: Region snapshot generator

class RegionSnapshotGenerator {
    static func generateSnapshot(for tdwgCode: String, size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
        guard let overlays = GeoJSONLoader.loadOverlay(for: tdwgCode),
              let overlay = overlays.first else {
            completion(nil)
            return
        }

        let region = MKCoordinateRegion(overlay.boundingMapRect)
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.scale = UIScreen.main.scale

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }

            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            snapshot.image.draw(at: .zero)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            completion(image)
        }
    }
}

class GeoJSONManager {
    static let shared = GeoJSONManager()
    
    private var featuresByLevel: [Int: [MKGeoJSONObject]] = [:]
    
    private init() {
        loadGeoJSON(forLevel: 1)
        loadGeoJSON(forLevel: 2)
        loadGeoJSON(forLevel: 3)
        loadGeoJSON(forLevel: 4)
    }

    private func loadGeoJSON(forLevel level: Int) {
        guard let url = Bundle.main.url(forResource: "tdwg-level\(level)", withExtension: "geojson", subdirectory: "GeoJSONData") else {
            print("❌ Could not find tdwg-level\(level).geojson")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let objects = try MKGeoJSONDecoder().decode(data)
            featuresByLevel[level] = objects
        } catch {
            print("❌ Failed to load level \(level) GeoJSON: \(error)")
        }
    }

    func overlayForRegion(code: String, level: Int) -> MKOverlay? {
        guard let features = featuresByLevel[level] else { return nil }

        for feature in features.compactMap({ $0 as? MKGeoJSONFeature }) {
            if let properties = feature.properties,
               let json = try? JSONSerialization.jsonObject(with: properties) as? [String: Any],
               let tdwgCode = json["TDWG_CODE"] as? String,
               tdwgCode.uppercased() == code.uppercased() {

                return feature.geometry.first(where: { $0 is MKPolygon }) as? MKPolygon
            }
        }
        return nil
    }
}

extension MKCoordinateRegion {
    static var world: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
    }
}

