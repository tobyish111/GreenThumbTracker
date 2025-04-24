//
//  DistributionExplorer.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/22/25.
//

import SwiftUI
import MapKit

struct DistributionExplorer: View {
    let regions: [DistributionRegion]
       let tdwgCodes: [String]

       @State private var focusRegionCode: String? = nil
       @State private var overlays: [String: MKPolygon] = [:]
       @State private var showAllRegions: Bool = false

       private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

       var body: some View {
           VStack(spacing: 16) {
               Text("Distribution Map")
                   .font(.headline)
                   .frame(maxWidth: .infinity, alignment: .leading)

               MapRepresentable(
                   tdwgCodes: tdwgCodes,
                   focusCode: $focusRegionCode,
                   regionOverlays: $overlays
               )
               .frame(height: 300)
               .cornerRadius(12)
               .shadow(radius: 4)
               
               Text("Found in \(regions.count) region\(regions.count == 1 ? "" : "s")")
                   .font(.subheadline)
                   .foregroundColor(.primary)
                   .padding(.bottom, 4)
                   .frame(maxWidth: .infinity, alignment: .center)
               Divider()

               if !regions.isEmpty {
                   var visibleRegions: [DistributionRegion] {
                       if showAllRegions {
                           return regions
                       } else {
                           return Array(regions.prefix(12))
                       }
                   }


                   LazyVGrid(columns: columns, spacing: 12) {
                       ForEach(visibleRegions, id: \.id) { region in
                           Button {
                               focusRegionCode = region.tdwg_code
                           } label: {
                               HStack(spacing: 4) {
                                   Image(systemName: "leaf.fill")
                                       .foregroundColor(.green)
                                   Text(region.name)
                                       .font(.caption)
                                       .foregroundColor(.primary)
                                       .lineLimit(1)
                               }
                               .padding(6)
                               .frame(maxWidth: .infinity)
                               .background(Color.zenBeige.opacity(0.2))
                               .cornerRadius(8)
                           }
                       }
                   }

                   if regions.count > 12 {
                       Button(action: {
                           withAnimation {
                               showAllRegions.toggle()
                           }
                       }) {
                           Text(showAllRegions ? "Show Less" : "Show More")
                               .font(.caption)
                               .foregroundColor(.blue)
                               .padding(.top, 4)
                       }
                   }
               } else {
                   Text("No distribution data available.")
                       .foregroundColor(.gray)
               }
           }
           .padding()
           .background(Color.white.opacity(0.9))
           .cornerRadius(12)
           .shadow(radius: 4)
       }
   }   /*
#Preview {
    DistributionExplorer()
}
*/
