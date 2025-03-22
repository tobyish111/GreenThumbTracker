//
//  PlantVIew.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/21/25.
//
//template for each plant

import SwiftUI

struct PlantVIew: View {
    let plant: Plant
        @State var growthRecords: [GrowthRecord] = []
        @State var waterRecords: [WaterRecord] = []
        @State var unitMap: [Int: UnitOfMeasure] = [:] // map UOM id to object

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Basic Info
                    Text(plant.name)
                        .font(.largeTitle)
                        .bold()
                    Text("Species: \(plant.species)")
                        .font(.subheadline)
                    Divider()

                    // Latest Growth
                    if let latestGrowth = growthRecords.sorted(by: { $0.date > $1.date }).first {
                        VStack(alignment: .leading) {
                            Text("Latest Growth:")
                                .font(.headline)
                            Text("\(latestGrowth.height, specifier: "%.2f") \(unitMap[latestGrowth.uomID]?.symbol ?? "") on \(latestGrowth.date)")
                        }
                    }

                    // Watering Log
                    VStack(alignment: .leading) {
                        Text("Watering Records")
                            .font(.headline)
                        ForEach(waterRecords.sorted(by: { $0.date > $1.date })) { record in
                            HStack {
                                Text(record.date)
                                Spacer()
                                Text("\(record.amount) \(unitMap[record.uomID]?.symbol ?? "")")
                            }
                            .font(.subheadline)
                            .padding(.vertical, 4)
                        }
                    }

                    // Actions
                    HStack {
                        Button("Add Growth") {
                            // Show growth input form
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Add Water") {
                            // Show water input form
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("Plant Details")
            .onAppear {
                loadGrowthData()
                loadWaterData()
            }
        }

        // Stub loading methods
        func loadGrowthData() {
            // API call to backend → populate growthRecords
        }

        func loadWaterData() {
            // API call to backend → populate waterRecords
        }
}

#Preview {
    let testPlant: Plant = Plant(id: 1, name: "Test Plant", species: "Test Species", userID: 1)
    PlantVIew(plant: testPlant)
}
