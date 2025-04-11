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
    @State private var growthSuccessBanner: String?
    @State private var showingGrowthForm = false
    @State private var showingGrowthEditSheet = false
    @State private var showWaterChart = false


    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.5), .green.opacity(0.8)],
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
                    // Growth Log Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Label("Growth Records", systemImage: "arrow.up.right.circle.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                            Spacer()

                            Button(action: {
                                loadGrowthData()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.green)
                            }.offset(x: -35)
                            .buttonStyle(.borderless)
                            .help("Refresh Data")

                            Spacer()

                            Button(action: {
                                showingGrowthForm = true
                            }) {
                                Text("Add")
                                    .foregroundColor(.green)
                                Image(systemName: "plus")
                                    .foregroundColor(.green)
                            }
                            .sheet(isPresented: $showingGrowthForm) {
                                AddGrowthSheetView(
                                    plant: plant,
                                    onSubmit: {
                                        showingGrowthForm = false
                                        loadGrowthData()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            withAnimation {
                                                growthSuccessBanner = "Growth record added!"
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                withAnimation {
                                                    growthSuccessBanner = nil
                                                }
                                            }
                                        }
                                    }
                                )
                            }


                            Spacer()

                            Button {
                                showingGrowthEditSheet = true
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.green)
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(.borderless)
                            .help("Edit")
                        }
                        .sheet(isPresented: $showingGrowthEditSheet) {
                            GrowthRecordEditView(
                                plant: plant,
                                growthRecords: $growthRecords,
                                unitMap: unitMap,
                                refreshData: loadGrowthData,
                                deleteGrowthRecord: deleteGrowthRecord
                            )
                        }

                        HStack {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Entries: \(growthRecords.count)")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.leading)
                            Spacer()
                            Text("Height")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        if growthRecords.isEmpty {
                            Text("...No growth records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(growthRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                                .font(.subheadline)
                                            Spacer()
                                            Text("\(record.height, specifier: "%.2f") \(unitMap[record.uom.id]?.symbol ?? "")")
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
                    //end growth log section
                    
                    //Watering Log Section
                    VStack(alignment: .leading, spacing: 12) {
                        //Section Title with total entries
                        //chart headers
                        HStack(spacing: 10) {
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
                                Text("Add")
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
                                refreshData: loadWaterData,
                                deleteWaterRecord: deleteWaterRecord
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
                            }//end water scroll view
                            .frame(maxHeight: 200)
                            .overlay(alignment: .bottom) {
                                Button(action: {
                                    // trigger navigation to chart view
                                    showWaterChart = true
                                }) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                        Text("View Water Chart")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.85))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .padding()
                                }
                                .fullScreenCover(isPresented: $showWaterChart) {
                                    NavigationView {
                                        WaterChartView(waterRecords: waterRecords, unitMap: unitMap)
                                    }
                                }
                            }

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
        APIManager.shared.fetchGrowthRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.growthRecords = records
                case .failure(let error):
                    print("Failed to load growth records: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteGrowthRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteGrowthRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadGrowthData()
            case .failure(let error):
                print("Failed to delete growth record:", error.localizedDescription)
            }
        }
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
