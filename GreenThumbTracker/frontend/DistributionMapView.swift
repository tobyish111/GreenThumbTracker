//
//  DistributionMapView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/17/25.
//

import SwiftUI
import MapKit

struct DistributionMapView: View {
    let tdwgCodes: [String]
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 180)
        )
    )
    @State private var focusCode: String? = nil
      @State private var regionOverlays: [String: MKPolygon] = [:]



       var body: some View {
           ZStack(alignment: .topLeading) {
               ZStack {
                        Map(position: $cameraPosition) { }
                                  .frame(height: 300)
                                  .cornerRadius(12)
                                  .shadow(radius: 4)

                              // 👇 Place MapRepresentable *above* as sibling, NOT inside GeometryReader
                   MapRepresentable(tdwgCodes: tdwgCodes, focusCode: $focusCode, regionOverlays: $regionOverlays)
                                  .frame(height: 300)
                                  .cornerRadius(12)
                                  .clipped()
                                  .allowsHitTesting(false) // optional: disables interaction with raw overlay
                          }

               // Optional: Show the codes or legend in top left
               if !tdwgCodes.isEmpty {
                   VStack(alignment: .leading, spacing: 4) {
                       ForEach(tdwgCodes.prefix(3), id: \.self) { code in
                           Text("Region: \(code)")
                               .font(.caption)
                               .foregroundColor(.white)
                               .padding(.horizontal, 6)
                               .background(Color.black.opacity(0.6))
                               .cornerRadius(4)
                       }
                       if tdwgCodes.count > 3 {
                           Text("+ \(tdwgCodes.count - 3) more regions")
                               .font(.caption2)
                               .foregroundColor(.white.opacity(0.8))
                       }
                   }
                   .padding(8)
               }
           }
       }
   }


/*
#Preview {
    DistributionMapView()
}
*/
