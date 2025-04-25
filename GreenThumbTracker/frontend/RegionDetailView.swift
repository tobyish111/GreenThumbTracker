//
//  RegionDetailView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI

struct RegionDetailView: View {
    let slug: String
    @State private var plants: [TreflePlant] = []
        @State private var regionDetails: TrefleDistributionRegionDetails?
        @State private var errorMessage: String?

        var body: some View {
            ZStack {
                LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                if let region = regionDetails {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 8) {
                                Text(region.name)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.green)

                                Text("TDWG Code: \(region.tdwg_code)")
                                    .font(.headline)

                                Text("Level: \(region.tdwg_level)")
                                    .font(.subheadline)

                                Text("Species Count: \(region.species_count)")
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 4)

                            // Parent Region
                            if let parent = region.parent {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Parent Region")
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    Text("🌍 \(parent.name)")
                                    Text("TDWG Code: \(parent.tdwg_code)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                            // Static Image for Region (if available)
                            if let staticImage = UIImage(named: "\(region.tdwg_code.uppercased()).png") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Region Preview")
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    Image(uiImage: staticImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }


                            // Child Regions
                            if !region.children.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Child Regions")
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    ForEach(region.children, id: \.id) { child in
                                        VStack(alignment: .leading) {
                                            Text("🌱 \(child.name)")
                                                .font(.subheadline)
                                            Text("TDWG Code: \(child.tdwg_code)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(8)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(10)
                                        .shadow(radius: 1)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                            if !plants.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Plants in this Region")
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    ForEach(plants) { plant in
                                        NavigationLink(destination: TreflePlantView(plant: plant)) {
                                            Text(plant.common_name ?? plant.scientific_name)
                                                .padding(8)
                                                .background(Color.white.opacity(0.8))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding()
                            }

                        }
                        .padding()
                    }
                } else if let error = errorMessage {
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView("Loading region details...")
                }
            }
            .navigationTitle("Region Details")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadRegionDetails()
                loadPlantsInRegion()
            }
        }

        private func loadRegionDetails() {
            if let cached = TrefleRegionDetailsCache.shared.regionDetailsMap[slug] {
                self.regionDetails = cached
                return
            }

            TrefleAPI.shared.getDistributionDetails(slug: slug) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let details):
                        TrefleRegionDetailsCache.shared.regionDetailsMap[slug] = details
                        self.regionDetails = details
                    case .failure(let err):
                        self.errorMessage = err.localizedDescription
                    }
                }
            }
        }
    private func loadPlantsInRegion() {
        TrefleAPI.shared.getPlantsInRegion(slug: slug) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPlants):
                    self.plants = fetchedPlants
                case .failure(let err):
                    print("❌ Failed to fetch plants for region \(slug): \(err.localizedDescription)")
                }
            }
        }
    }

    }

/*
#Preview {
    RegionDetailView()
}
*/
