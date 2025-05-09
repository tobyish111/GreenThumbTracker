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
    @State private var showGrowthChart = false
    @State private var showWaterChart = false
    @State private var humidityRecords: [HumidityRecord] = []
    @State private var showingHumidityEditSheet = false
    @State private var showingHumidityForm = false
    @State private var showHumidityChart = false
    @State private var lightRecords: [LightRecord] = []
    @State private var showingLightForm = false
    @State private var showingLightEditSheet = false
    @State private var showLightChart = false
    @State private var soilMoistureRecords: [SoilMoistureRecord] = []
    @State private var showingSoilMoistureForm = false
    @State private var showingSoilMoistureEditSheet = false
    @State private var showSoilMoistureChart = false
    @State private var temperatureRecords: [TemperatureRecord] = []
    @State private var showingTemperatureForm = false
    @State private var showingTemperatureEditSheet = false
    @State private var showTemperatureChart = false
    @State private var showMultiTrendChart = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var inputImage: UIImage?

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
                        //MARK: Delete Image button
                        if selectedImage != nil {
                            Button(role: .destructive) {
                                PlantImageManager.deleteImage(for: plant.id)
                                self.selectedImage = nil
                            } label: {
                                Label("Delete Photo", systemImage: "trash")
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
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
                    //MARK: Image ZStack
                    ZStack {
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 180)
                            .cornerRadius(12)

                        if let savedImage = PlantImageManager.loadImage(for: plant.id) {
                            Image(uiImage: savedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            VStack {
                                Image(systemName: "leaf.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.green.opacity(0.6))
                                Text("Tap to Add Photo")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onTapGesture {
                        let alert = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                            sourceType = .camera
                            showingImagePicker = true
                        })
                        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            
                            // ✅ Fix: Handle iPad popover requirements
                            if let popover = alert.popoverPresentationController, UIDevice.current.userInterfaceIdiom == .pad {
                                popover.sourceView = rootVC.view
                                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX,
                                                            y: rootVC.view.bounds.midY,
                                                            width: 0,
                                                            height: 0)
                                popover.permittedArrowDirections = []
                            }
                            
                            rootVC.present(alert, animated: true)
                        }
                    }


                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(sourceType: sourceType, image: $selectedImage)
                    }
                    .onChange(of: selectedImage) { _, newImage in
                        if let image = newImage {
                            PlantImageManager.saveImage(image, for: plant.id)
                            self.selectedImage = PlantImageManager.loadImage(for: plant.id)
                        }
                    }
                    
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
                    //MARK: Growth Records
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
                        Button(action: {
                            showGrowthChart = true
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("View Growth Chart")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .fullScreenCover(isPresented: $showGrowthChart) {
                            NavigationView {
                                GrowthChartView(growthRecords: growthRecords, unitMap: unitMap)
                            }
                        }

                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    //end growth log section
                    
                    //Watering Log Section
                    //MARK: Water Records
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
                            }
                            .fullScreenCover(isPresented: $showWaterChart) {
                                NavigationView {
                                    WaterChartView(waterRecords: waterRecords, unitMap: unitMap)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    //end water records
                    
                    //humidity records
                    //MARK: Humidity Records
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Label("Humidity Records", systemImage: "humidity.fill")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Spacer()
                            Button(action: {
                                loadHumidityData()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.orange)
                            }.offset(x: -35)
                            .buttonStyle(.borderless)

                            Spacer()
                                Button(action: {
                                    showingHumidityForm = true
                                }) {
                                    Text("Add")
                                        .foregroundColor(.orange)
                                    Image(systemName: "plus")
                                        .foregroundColor(.orange)
                                }.sheet(isPresented: $showingHumidityForm) {
                                    AddHumiditySheetView(
                                        plant: plant,
                                        onSubmit: {
                                            showingHumidityForm = false
                                            loadHumidityData()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                withAnimation {
                                                    // You can optionally set a success banner message here
                                                }
                                            }
                                        }
                                    )
                                }
                            Spacer()
                            Button {
                                showingHumidityEditSheet = true
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.orange)
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.orange)
                            }
                            .buttonStyle(.borderless)
                        }
                        .sheet(isPresented: $showingHumidityEditSheet) {
                            HumidityRecordEditView(
                                plant: plant,
                                humidityRecords: $humidityRecords,
                                refreshData: loadHumidityData,
                                deleteHumidityRecord: deleteHumidityRecord
                            )
                        }

                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Entries: \(humidityRecords.count)")
                            Spacer()
                            Text("Humidity %")
                        }.font(.subheadline).foregroundColor(.gray)

                        if humidityRecords.isEmpty {
                            Text("...No humidity records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(humidityRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                            Spacer()
                                            Text("\(record.humidity, specifier: "%.1f")%")
                                                .foregroundColor(.black)
                                        }
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                    }
                                }.padding(.top, 4)
                            }
                            .frame(maxHeight: 200)

                            Button(action: {
                                showHumidityChart = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                    Text("View Humidity Chart")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $showHumidityChart) {
                                NavigationView {
                                    HumidityChartView(humidityRecords: humidityRecords)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)

                    //light records
                    //MARK: Light Records
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Label("Light Records", systemImage: "sun.max.fill")
                                .font(.headline)
                                .foregroundColor(.yellow)

                            Spacer()

                            Button(action: {
                                loadLightData()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.yellow)
                            }
                            .offset(x: -35)
                            .buttonStyle(.borderless)

                            Spacer()

                            Button(action: {
                                showingLightForm = true
                            }) {
                                Text("Add")
                                    .foregroundColor(.yellow)
                                Image(systemName: "plus")
                                    .foregroundColor(.yellow)
                            }
                            .sheet(isPresented: $showingLightForm) {
                                AddLightSheet(
                                    plant: plant,
                                    onSubmit: {
                                        showingLightForm = false
                                        loadLightData()
                                    }
                                )
                            }

                            Spacer()

                            Button {
                                showingLightEditSheet = true
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.yellow)
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.yellow)
                            }
                            .buttonStyle(.borderless)
                            .help("Edit")
                        }

                        .sheet(isPresented: $showingLightEditSheet) {
                            LightRecordEditView(
                                plant: plant,
                                lightRecords: $lightRecords,
                                refreshData: loadLightData,
                                deleteLightRecord: deleteLightRecord
                            )
                        }

                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Entries: \(lightRecords.count)")
                            Spacer()
                            Text("Light")
                        }.font(.subheadline).foregroundColor(.gray)

                        if lightRecords.isEmpty {
                            Text("...No light records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(lightRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                            Spacer()
                                            Text("\(record.light, specifier: "%.1f")")
                                                .foregroundColor(.black)
                                        }
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxHeight: 200)

                            Button(action: {
                                showLightChart = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                    Text("View Light Chart")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $showLightChart) {
                                NavigationView {
                                    LightRecordChartView(lightRecords: lightRecords)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    //soil records
                    //MARK: Soil Records
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Label("Soil Moisture Records", systemImage: "drop.triangle.fill")
                                .font(.headline)
                                .foregroundColor(.brown)

                            Spacer()

                            Button(action: {
                                loadSoilMoistureData()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.brown)
                            }
                            .offset(x: -35)
                            .buttonStyle(.borderless)

                            Spacer()

                            Button(action: {
                                showingSoilMoistureForm = true
                            }) {
                                Text("Add")
                                    .foregroundColor(.brown)
                                Image(systemName: "plus")
                                    .foregroundColor(.brown)
                            }
                            .sheet(isPresented: $showingSoilMoistureForm) {
                                AddSoilMoistureSheet(
                                    plant: plant,
                                    onSubmit: {
                                        showingSoilMoistureForm = false
                                        loadSoilMoistureData()
                                    }
                                )
                            }

                            Spacer()

                            Button {
                                showingSoilMoistureEditSheet = true
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.brown)
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.brown)
                            }
                            .buttonStyle(.borderless)
                        }

                        .sheet(isPresented: $showingSoilMoistureEditSheet) {
                            SoilMoistureRecordEditView(
                                plant: plant,
                                soilMoistureRecords: $soilMoistureRecords,
                                refreshData: loadSoilMoistureData,
                                deleteSoilMoistureRecord: deleteSoilMoistureRecord
                            )
                        }

                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Entries: \(soilMoistureRecords.count)")
                            Spacer()
                            Text("Moisture")
                        }.font(.subheadline).foregroundColor(.gray)

                        if soilMoistureRecords.isEmpty {
                            Text("...No soil moisture records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(soilMoistureRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                            Spacer()
                                            Text("\(record.soil_moisture, specifier: "%.1f")")
                                                .foregroundColor(.black)
                                        }
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxHeight: 200)

                            Button(action: {
                                showSoilMoistureChart = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                    Text("View Moisture Chart")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.brown.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $showSoilMoistureChart) {
                                NavigationView {
                                    SoilMoistureChartView(soilMoistureRecords: soilMoistureRecords)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)

                    //temp records
                    //MARK: Temperature Records
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Label("Temperature Records", systemImage: "thermometer.sun.fill")
                                .font(.headline)
                                .foregroundColor(.red)

                            Spacer()

                            Button(action: {
                                loadTemperatureData()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.red)
                            }
                            .offset(x: -35)
                            .buttonStyle(.borderless)

                            Button(action: {
                                showingTemperatureForm = true
                            }) {
                                Text("Add")
                                    .foregroundColor(.red)
                                Image(systemName: "plus")
                                    .foregroundColor(.red)
                            }
                            .sheet(isPresented: $showingTemperatureForm) {
                                AddTemperatureSheet(
                                    plant: plant,
                                    onSubmit: {
                                        showingTemperatureForm = false
                                        loadTemperatureData()
                                    }
                                )
                            }

                            Spacer()

                            Button {
                                showingTemperatureEditSheet = true
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.red)
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }

                        .sheet(isPresented: $showingTemperatureEditSheet) {
                            TemperatureRecordEditView(
                                plant: plant,
                                temperatureRecords: $temperatureRecords,
                                refreshData: loadTemperatureData,
                                deleteTemperatureRecord: deleteTemperatureRecord
                            )
                        }

                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Entries: \(temperatureRecords.count)")
                            Spacer()
                            Text("Temp")
                        }.font(.subheadline).foregroundColor(.gray)

                        if temperatureRecords.isEmpty {
                            Text("...No temperature records yet...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(temperatureRecords.sorted(by: { $0.date > $1.date })) { record in
                                        HStack {
                                            Text(formattedDate(record.date))
                                            Spacer()
                                            Text("\(record.temperature, specifier: "%.1f")°")
                                                .foregroundColor(.black)
                                        }
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxHeight: 200)

                            Button(action: {
                                showTemperatureChart = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                    Text("View Temp Chart")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            }
                            .fullScreenCover(isPresented: $showTemperatureChart) {
                                NavigationView {
                                    TemperatureChartView(temperatureRecords: temperatureRecords)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    //Multi-Record Trend Button
                    //MARK: Multi-Triend
                    VStack(spacing: 12) {
                        Button(action: {
                            showMultiTrendChart = true
                            print("📊 Navigating to MultiRecordTrendView")

                        }) {
                            HStack {
                                Image(systemName: "waveform.path.ecg.rectangle")
                                Text("Compare Multiple Trends")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .fullScreenCover(isPresented: $showMultiTrendChart) {
                            NavigationView {
                                MultiRecordTrendView(
                                    plant: plant,
                                    growthRecords: growthRecords,
                                    waterRecords: waterRecords,
                                    humidityRecords: humidityRecords,
                                    lightRecords: lightRecords,
                                    soilMoistureRecords: soilMoistureRecords,
                                    temperatureRecords: temperatureRecords,
                                    unitMap: unitMap
                                )
                            }
                        }
                    }

                    Spacer()
                }//end main vstack
                .padding()
            }
            .navigationTitle("Plant Details")
            .onAppear {
                self.selectedImage = PlantImageManager.loadImage(for: plant.id)
                loadGrowthData()
                loadWaterData()
                loadHumidityData()
                loadLightData()
                loadSoilMoistureData()
                loadTemperatureData()
            }
        }//end zstack
        .sheet(isPresented: $showingEditSheet) {
            AddPlantView(existingPlant: plant)
        }

    }
    //MARK: END VIEW
    // MARK: - Temperature Record Operations
    func loadTemperatureData() {
        APIManager.shared.fetchTemperatureRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.temperatureRecords = records
                case .failure(let error):
                    print("❌ Failed to load temperature records: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteTemperatureRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteTemperatureRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadTemperatureData()
            case .failure(let error):
                print("❌ Failed to delete temperature record: \(error.localizedDescription)")
            }
        }
    }

    //MARK: Soil methods
    func loadSoilMoistureData() {
        APIManager.shared.fetchSoilMoistureRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.soilMoistureRecords = records
                case .failure(let error):
                    print("❌ Failed to load soil moisture records: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteSoilMoistureRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteSoilMoistureRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadSoilMoistureData()
            case .failure(let error):
                print("❌ Failed to delete soil moisture record: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Light Record Operations
    func loadLightData() {
        APIManager.shared.fetchLightRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.lightRecords = records
                case .failure(let error):
                    print("❌ Failed to load light records: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteLightRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteLightRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadLightData()
            case .failure(let error):
                print("❌ Failed to delete light record: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Humidity Record Operations
    func loadHumidityData() {
        APIManager.shared.fetchHumidityRecords(forPlantId: plant.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.humidityRecords = records
                case .failure(let error):
                    print("❌ Failed to load humidity records: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteHumidityRecord(plantId: Int, recordId: Int) {
        APIManager.shared.deleteHumidityRecord(plantId: plantId, recordId: recordId) { result in
            switch result {
            case .success:
                loadHumidityData()
            case .failure(let error):
                print("❌ Failed to delete humidity record: \(error.localizedDescription)")
            }
        }
    }

    //MARK: - Growth Record Operations
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
    //MARK: Water Record Operations
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
