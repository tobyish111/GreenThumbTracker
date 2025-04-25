//
//  TrefleRegionMapPreviewView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI
import MapKit

struct TrefleRegionMapPreviewView: View {
    let tdwgCode: String
        let tdwgLevel: Int

        @State private var overlay: MKOverlay?

        var body: some View {
            Map(coordinateRegion: .constant(MKCoordinateRegion.world), interactionModes: [])
                .overlay(
                    GeometryReader { _ in
                        MapOverlay(overlay: overlay)
                    }
                )
                .onAppear {
                    self.overlay = GeoJSONManager.shared.overlayForRegion(code: tdwgCode, level: tdwgLevel)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }

    struct MapOverlay: UIViewRepresentable {
        let overlay: MKOverlay?

        func makeUIView(context: Context) -> MKMapView {
            let map = MKMapView()
            map.isUserInteractionEnabled = false
            return map
        }

        func updateUIView(_ mapView: MKMapView, context: Context) {
            mapView.removeOverlays(mapView.overlays)
            if let overlay = overlay {
                mapView.addOverlay(overlay)
                mapView.setVisibleMapRect(overlay.boundingMapRect, animated: false)
            }
        }
        func makeCoordinator() -> Coordinator {
                Coordinator()
            }

            class Coordinator: NSObject, MKMapViewDelegate {
                func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                    if let polygon = overlay as? MKPolygon {
                        let renderer = MKPolygonRenderer(polygon: polygon)
                        renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
                        renderer.strokeColor = UIColor.green
                        renderer.lineWidth = 1
                        return renderer
                    } else if let multiPolygon = overlay as? MKMultiPolygon {
                        let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
                        renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
                        renderer.strokeColor = UIColor.green
                        renderer.lineWidth = 1
                        return renderer
                    }

                    return MKOverlayRenderer(overlay: overlay)
                }
            }
        }
    
/*
#Preview {
    TrefleRegionMapPreviewView()
}
*/
