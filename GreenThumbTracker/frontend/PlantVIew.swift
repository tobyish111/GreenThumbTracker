//
//  PlantVIew.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/21/25.
//
//template for each plant

import SwiftUI

struct PlantView: View {
    let plant: Plant
    var namespace: Namespace.ID
    @State var growthRecords: [GrowthRecord] = []
    @State var waterRecords: [WaterRecord] = []
    @State var unitMap: [Int: UnitOfMeasure] = [:] // map UOM id to object
    @State private var showingWaterForm = false
    @State private var waterSuccessBanner: String?
    @State private var showingWaterEditSheet = false
    @State private var showingEditSheet = false

    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.green)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }//end hstack
                    .padding(.top, 10)
                    .padding(.trailing)

                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
                        .padding(.top, 20)
                    
                    //confirmation message
                    if let message = waterSuccessBanner {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white)
                            Text(message)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    //Plant Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plant.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Species: \(plant.species)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    //Latest Growth
                    if let latestGrowth = growthRecords.sorted(by: { $0.date > $1.date }).first {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Latest Growth", systemImage: "leaf")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("\(latestGrowth.height, specifier: "%.2f") \(unitMap[latestGrowth.uomID]?.symbol ?? "")")
                                .font(.title2)
                                .bold()
                            
                            Text("on \(latestGrowth.date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    //Watering Log Section
                    VStack(alignment: .leading, spacing: 12) {
                        //Section Title with total entries
                        //chart headers
                        HStack(spacing: 12) {
                            Label("Watering Records", systemImage: "drop.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Spacer()
                            
                            Button(action: {
                                loadWaterData()
                            }){
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }.offset(x: -35)
                            .buttonStyle(.borderless)
                            .help("Refresh Data")
                            Spacer()
                            //place add water button here!!!
                            Button(action: {
                                showingWaterForm = true
                            }) {
                                
                                Image(systemName: "plus")
                            }
                            Spacer()
                            Button {
                                showingWaterEditSheet = true
                            } label: {
                                Text("Edit")
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                            .help("Edit")
                        }
                        .sheet(isPresented: $showingWaterEditSheet) {
                            WaterRecordEditView(
                                plant: plant,
                                waterRecords: $waterRecords,
                                unitMap: unitMap,
                                refreshData: loadWaterData
                            )
                        }
                        //Column Headers
                        HStack {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Entries: \(waterRecords.count)")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.leading)
                            Spacer()
                            Text("Amount")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        //Empty state
                        if waterRecords.isEmpty {
                            Text("...No water records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            //Scrollable and Refreshable List
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(waterRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(record.amount) \(unitMap[record.uomID]?.symbol ?? "")")
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    //end water records
                    
                    
                    //Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            //Show growth input form
                        }) {
                            Label("Add Growth", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        //add water record button
                        Button(action: {
                            showingWaterForm = true
                        }) {
                            Label("Add Water Record", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                        .sheet(isPresented: $showingWaterForm) {
                            AddWaterSheet(
                                plant: plant,
                                onSubmit: {
                                    showingWaterForm = false
                                    loadWaterData()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        withAnimation {
                                            waterSuccessBanner = "Water record added!"
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                waterSuccessBanner = nil
                                            }
                                        }
                                    }
                                }
                            )
                        }

                    }//end hstack
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Plant Details")
            .onAppear {
                loadGrowthData()
                loadWaterData()
            }
        }//end zstack
        .sheet(isPresented: $showingEditSheet) {
            AddPlantView(existingPlant: plant)
        }

    }
    //loading methods for the UI
    func loadGrowthData() {
        // TODO: API call to populate growthRecords
    }
    //read water record
    func loadWaterData() {
        APIManager.shared.fetchWaterRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.waterRecords = records
                case .failure(let error):
                    print("Failed to load water records: \(error.localizedDescription)")
                }
            }
        }
    }
    //delete water record
    func deleteWaterRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteWaterRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadWaterData()
            case .failure(let error):
                print("Failed to delete water record:", error.localizedDescription)
            }
        }
    }
}

#Preview {
    let testPlant: Plant = Plant(id: 1, name: "Test Plant", species: "Test Species", userID: 1)
    let dm = Namespace().wrappedValue
    PlantView(plant: testPlant, namespace: dm)
}
