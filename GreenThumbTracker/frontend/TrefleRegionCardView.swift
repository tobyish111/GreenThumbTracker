//
//  TrefleRegionCardView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI
struct TrefleRegionCardView: View {
    let region: TrefleDistributionRegion

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Code: \(region.tdwg_code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Species: \(region.species_count)")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Static map image based on TDWG code
                let imageName = region.tdwg_code.uppercased()
     
                if let staticImage = UIImage(named: imageName) {
                    Text(imageName)
                    Image(uiImage: staticImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                } else {
                    Image(systemName: "globe.europe.africa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
            }

            .padding()
            .background(Color.white.opacity(0.95))
            .cornerRadius(12)
            .shadow(radius: 3)
        }
    }
/*
#Preview {
    TrefleRegionCardView()
}
*/
