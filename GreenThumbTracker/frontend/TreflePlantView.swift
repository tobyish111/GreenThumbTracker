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
    @State private var distributions: [DistributionRegion] = []
    @State private var isImageFullscreen = false

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
                        TrefleGrowthCard(growth: details.growth)
                        TrefleFlowerCard(flower: details.flower)
                        TrefleInfoCard(details: details)
                        TrefleDistributionCard(distributions: distributions)

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
            TrefleAPI.shared.getPlantDetails(id: plant.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let details):
                        self.plantDetails = details
                    case .failure(let error):
                        print("Failed to load details: \(error)")
                    }
                }
            }
            TrefleAPI.shared.getPlantDistributions(id: plant.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let regions):
                            self.distributions = regions
                            print("✅ Loaded \(regions.count) distribution regions.")
                        case .failure(let error):
                            print("Failed to load distributions: \(error)")
                        }
                    }
                }
        }
    }
}
//for mapkit
struct TrefleDistributionCard: View {
    let distributions: [DistributionRegion]

    // A rough central coordinate. Could be improved with averaging or geocoding TDWG codes later.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 180)
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Distribution", systemImage: "globe")
                .font(.headline)
                .foregroundColor(.blue)

            if distributions.isEmpty {
                Text("No distribution data available.")
                    .foregroundColor(.gray)
            } else {
                Map(initialPosition: .region(region)) {
                    // Placeholder for future pin annotations
                    ForEach(distributions.prefix(10)) { region in
                        // If you had coordinate data per region, you could show Annotation or Marker here
                        // For now, this is where you could add MapCircle or similar
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    VStack(alignment: .leading) {
                        ForEach(distributions.prefix(5)) { region in
                            HStack {
                                Image(systemName: region.native ? "leaf.fill" : "arrow.triangle.2.circlepath")
                                    .foregroundColor(region.native ? .green : .orange)
                                Text(region.name)
                            }
                        }
                        if distributions.count > 5 {
                            Text("+ \(distributions.count - 5) more regions...")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 8),
                    alignment: .topLeading
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4)
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
                    case .empty: ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .onTapGesture { withAnimation { isImageFullscreen = true } }
                    default: Image(systemName: "leaf")
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
struct TrefleGrowthCard: View {
    let growth: Growth?

    var body: some View {
        if let growth = growth {
            VStack(alignment: .leading, spacing: 8) {
                Label("Growth Info", systemImage: "leaf")
                    .font(.headline)
                    .foregroundColor(.green)

                if let light = growth.light {
                    Text("☀️ Light Requirement: \(light)/9")
                }
                if let minTemp = growth.minimum_temperature?.deg_c {
                    Text("🌡️ Min Temp: \(minTemp)°C")
                }
                if let maxTemp = growth.maximum_temperature?.deg_c {
                    Text("🌡️ Max Temp: \(maxTemp)°C")
                }
                if let phMin = growth.ph_minimum, let phMax = growth.ph_maximum {
                    Text("🧪 pH Range: \(phMin) – \(phMax)")
                }
                if let lifespan = growth.lifespan {
                    Text("🌱 Lifespan: \(lifespan.capitalized)")
                }
                if let rate = growth.growth_rate {
                    Text("📈 Growth Rate: \(rate.capitalized)")
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
}
struct TrefleFlowerCard: View {
    let flower: Flower?

    var body: some View {
        if let flower = flower, let color = flower.color {
            VStack(alignment: .leading, spacing: 8) {
                Label("Flower Info", systemImage: "florinsign.circle")
                    .font(.headline)
                    .foregroundColor(.pink)

                Text("🌸 Color: \(color.capitalized)")
                if let showy = flower.conspicuous {
                    Text(showy ? "🌟 Showy flower" : "🙈 Not very showy")
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
}
struct TrefleInfoCard: View {
    let details: TreflePlantDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Basic Info", systemImage: "info.circle")
                .font(.headline)
                .foregroundColor(.primary)

            if let family = details.family_common_name {
                Text("🌿 Family: \(family)")
            }
            if let genus = details.genus?.name {
                Text("🔎 Genus: \(genus)")
            }
            if details.vegetable == true {
                Text("🥗 Edible Plant")
            }
            if let ediblePart = details.edible_part {
                Text("🍴 Edible Part: \(ediblePart)")
            }
            if let toxicity = details.toxicity {
                Text("☠️ Toxicity: \(toxicity.capitalized)")
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
                                        .onEnded { _ in }
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
#Preview {
    let mockPlant = TreflePlant(
           id: 1,
           common_name: "Mock Lavender",
           scientific_name: "Lavandula angustifolia",
           image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lavandula_angustifolia_%28English_Lavender%29.jpg/800px-Lavandula_angustifolia_%28English_Lavender%29.jpg"
       )
       
    TreflePlantView(plant: mockPlant)
}
