//
//  TreflePlantView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import SwiftUI
import MapKit
struct TreflePlantView: View {
    let plant: TreflePlant
       @State private var plantDetails: TreflePlantDetails?
       @State private var isImageFullscreen = false
    @State private var forceRefresh = false

       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                   .ignoresSafeArea()

               ScrollView {
                   VStack(spacing: 24) {
                       PlantHeaderCard(plant: plant, isImageFullscreen: $isImageFullscreen)

                       if let details = plantDetails {
                           let species = details.main_species
                           Text("Loaded Plant: \(details.scientific_name)")
                               .foregroundColor(.blue)

                           TrefleInfoCard(details: details)
                           
                           
                           if let regions = species.distributions?.native {
                               DistributionExplorer(
                                   regions: regions,
                                   tdwgCodes: regions.compactMap { $0.tdwg_code }
                               )
                           }

                       } else {
                           ProgressView("Loading Plant Details...")
                       }

                       Spacer()
                   }
                   .padding()
               }
           }
           .navigationTitle("Details")
           .navigationBarTitleDisplayMode(.inline)
           .fullScreenCover(isPresented: $isImageFullscreen) {
               FullscreenZoomableImage(imageURL: plant.image_url ?? "", isPresented: $isImageFullscreen)
           }
           .onAppear {
               print("🌿 Fetching details for slug: \(plant.slug)")
               print("Plant id: \(plant.id)")
               TrefleAPI.shared.getPlantDetails(id: plant.id) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let details):
                           print("Successfully received plant details")
                           self.plantDetails = details
                           self.forceRefresh.toggle()
                           print("Debug plantDetails: \(details)")
                       case .failure(let error):
                           print("❌ Failed to load plant details: \(error)")
                       }
                   }
               }
           }
       }
   }

   struct PlantHeaderCard: View {
       let plant: TreflePlant
       @Binding var isImageFullscreen: Bool

       var body: some View {
           VStack(spacing: 16) {
               if let url = URL(string: plant.image_url ?? "") {
                   AsyncImage(url: url) { phase in
                       switch phase {
                       case .empty:
                           ProgressView()
                       case .success(let image):
                           image
                               .resizable()
                               .scaledToFit()
                               .onTapGesture {
                                   withAnimation { isImageFullscreen = true }
                               }
                       default:
                           Image(systemName: "leaf")
                       }
                   }
                   .frame(height: 200)
                   .cornerRadius(12)
                   .shadow(radius: 5)
               }

               Text(plant.common_name ?? "Unknown Plant")
                   .font(.largeTitle)
                   .fontWeight(.bold)
                   .foregroundColor(.green)

               Text(plant.scientific_name)
                   .font(.title2)
                   .foregroundColor(.gray)
           }
       }
   }

   struct TrefleInfoCard: View {
       let details: TreflePlantDetails

       var body: some View {
           let species = details.main_species
           VStack(alignment: .leading, spacing: 8) {
               Label("Basic Info", systemImage: "info.circle")
                   .font(.headline)
                   .foregroundColor(.primary)

               if let family = species.family?.name {
                   Text("🌿 Family: \(family)")
               }

               if let genus = species.genus?.name {
                   Text("🔎 Genus: \(genus)")
               }

               if let avgHeight = species.specifications?.average_height?.cm {
                   Text("📏 Avg Height: \(Int(avgHeight)) cm")
               }

               if let toxicity = species.specifications?.toxicity {
                   Text("☠️ Toxicity: \(toxicity)")
               }

               if let observations = details.observations {
                   Text("🗺️ Observations: \(observations)")
               }
           }
           .padding()
           .background(Color.white.opacity(0.9))
           .cornerRadius(12)
           .shadow(radius: 4)
       }
   }

   struct TrefleDistributionCard: View {
       let distributions: [DistributionRegion]

       var body: some View {
           VStack(alignment: .leading, spacing: 8) {
               Label("Distribution", systemImage: "globe")
                   .font(.headline)
                   .foregroundColor(.blue)

               if distributions.isEmpty {
                   Text("No distribution data available.")
                       .foregroundColor(.gray)
               } else {
                   ForEach(distributions.prefix(10)) { region in
                       HStack {
                           Image(systemName: "leaf.fill")
                               .foregroundColor(.green)
                           Text(region.name)
                       }
                   }
                   if distributions.count > 10 {
                       Text("+ \(distributions.count - 10) more regions...")
                           .font(.footnote)
                           .foregroundColor(.gray)
                   }
               }
           }
           .padding()
           .background(Color.white.opacity(0.9))
           .cornerRadius(12)
           .shadow(radius: 4)
       }
   }

   struct FullscreenZoomableImage: View {
       let imageURL: String
       @Binding var isPresented: Bool

       @State private var scale: CGFloat = 1.0
       @State private var offset: CGSize = .zero

       var body: some View {
           ZStack {
               Color.black.ignoresSafeArea()

               if let url = URL(string: imageURL) {
                   AsyncImage(url: url) { phase in
                       switch phase {
                       case .empty:
                           ProgressView()
                       case .success(let image):
                           image
                               .resizable()
                               .scaledToFit()
                               .scaleEffect(scale)
                               .offset(offset)
                               .gesture(
                                   SimultaneousGesture(
                                       MagnificationGesture()
                                           .onChanged { scale = max(1, $0) }
                                           .onEnded { _ in
                                               if scale < 1 { scale = 1 }
                                           },
                                       DragGesture()
                                           .onChanged { offset = $0.translation }
                                   )
                               )
                               .onTapGesture {
                                   withAnimation {
                                       isPresented = false
                                       scale = 1.0
                                       offset = .zero
                                   }
                               }
                       default:
                           Image(systemName: "leaf")
                       }
                   }
               }
           }
           .transition(.opacity)
           .animation(.easeInOut(duration: 0.3), value: isPresented)
       }
   }
/*
#Preview {
    let f = Family(name: "Lamiaceae", slug: "String")
    let g = Genus(name: "Lavandula", slug: "String")
    let mockPlant = TreflePlant(
           id: 123,
           slug: "mock-lavender",
           common_name: "Mock Lavender",
           scientific_name: "Lavandula angustifolia",
           image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lavandula_angustifolia_%28English_Lavender%29.jpg/800px-Lavandula_angustifolia_%28English_Lavender%29.jpg", genus: g,family: f
       )

       let mockDetails = TreflePlantDetails(
           id: 123,
           slug: "mock-lavender",
           common_name: "Mock Lavender",
           scientific_name: "Lavandula angustifolia",
           image_url: mockPlant.image_url,
           genus: Genus(name: "Lavandula", slug: "lavandula"),
           family: Family(name: "Lamiaceae", slug: "lamiaceae"),
           growth: Growth(
               light: 7,
               atmospheric_humidity: 45.0,
               minimum_temperature: Temperature(deg_c: 5.0),
               maximum_temperature: Temperature(deg_c: 30.0),
               ph_minimum: 6.0,
               ph_maximum: 8.0,
               soil_humidity: "dry",
               soil_texture: "sandy",
               soil_nutriments: "medium",
               soil_salinity: "low",
               growth_rate: "moderate",
               growth_form: "shrub",
               lifespan: "perennial"
           ),
           specifications: Specifications(average_height: Height(cm: 60)),
           flower: Flower(color: "purple", conspicuous: true)
       )
       
    TreflePlantView(plant: mockPlant)
}

*/
