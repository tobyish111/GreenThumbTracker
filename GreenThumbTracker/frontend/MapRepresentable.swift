import SwiftUI
import MapKit

struct MapRepresentable: UIViewRepresentable {
    let tdwgCodes: [String]
       @Binding var focusCode: String?
       @Binding var regionOverlays: [String: MKPolygon]

       func makeUIView(context: Context) -> MKMapView {
           let mapView = MKMapView()
           mapView.delegate = context.coordinator
           mapView.isZoomEnabled = true
           mapView.isScrollEnabled = true
           mapView.isRotateEnabled = false
           mapView.isPitchEnabled = false

           DispatchQueue.global(qos: .userInitiated).async {
               loadSafeOverlays { overlaysDict in
                   DispatchQueue.main.async {
                       regionOverlays = overlaysDict
                       mapView.addOverlays(Array(overlaysDict.values))

                       let union = overlaysDict.values.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
                       mapView.setVisibleMapRect(union, edgePadding: .init(top: 40, left: 40, bottom: 40, right: 40), animated: false)
                   }
               }
           }

           return mapView
       }

       func updateUIView(_ uiView: MKMapView, context: Context) {
           if let code = focusCode?.uppercased(), let polygon = regionOverlays[code] {
               uiView.setVisibleMapRect(polygon.boundingMapRect, edgePadding: .init(top: 40, left: 40, bottom: 40, right: 40), animated: true)
           }
       }

       func makeCoordinator() -> Coordinator { Coordinator() }

       private func loadSafeOverlays(completion: @escaping ([String: MKPolygon]) -> Void) {
           guard let url = Bundle.main.url(forResource: "maps", withExtension: "geojson") else {
               print("❌ GeoJSON file not found.")
               completion([:])
               return
           }

           do {
               let raw = try String(contentsOf: url, encoding: .utf8)
               let data = Data(raw.utf8)
               let features = try MKGeoJSONDecoder().decode(data)

               var result: [String: MKPolygon] = [:]

               for case let feature as MKGeoJSONFeature in features {
                   guard let props = feature.properties,
                         let dict = try? JSONSerialization.jsonObject(with: props) as? [String: Any],
                         let code = dict["LEVEL3_COD"] as? String,
                         tdwgCodes.contains(where: { $0.uppercased() == code.uppercased() }) else { continue }

                   for geometry in feature.geometry {
                       guard let polygon = geometry as? MKPolygon else { continue }

                       var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polygon.pointCount)
                       polygon.getCoordinates(&coords, range: NSRange(location: 0, length: polygon.pointCount))

                       let valid = coords
                           .map { $0.safeForMapKit() }
                           .filter { $0.isValidForMapKit }

                       if valid.count >= 3 {
                           result[code.uppercased()] = MKPolygon(coordinates: valid, count: valid.count)
                       }
                   }
               }

               completion(result)

           } catch {
               print("❌ Failed to parse geojson: \(error)")
               completion([:])
           }
       }

       class Coordinator: NSObject, MKMapViewDelegate {
           func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
               guard let polygon = overlay as? MKPolygon else {
                   return MKOverlayRenderer(overlay: overlay)
               }
               let r = MKPolygonRenderer(polygon: polygon)
               r.fillColor = UIColor.systemGreen.withAlphaComponent(0.4)
               r.strokeColor = UIColor.green
               r.lineWidth = 1
               return r
           }
       }
   }
