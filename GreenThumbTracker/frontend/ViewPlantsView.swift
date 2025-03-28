//
//  ViewPlantsView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/22/25.
//

import SwiftUI

struct ViewPlantsView: View {
    @State private var plants: [Plant] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Namespace private var navNamespace
    @State private var showDeleteConfirmation = false
    @State private var plantToDelete: Plant?
    @State private var deletionMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                gradientBackground

                VStack(spacing: 16) {
                    HStack {
                        Text("My Plants")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                            .padding()
                        Spacer()

                        if !plants.isEmpty {
                            Text("Total Plants: \(plants.count)")
                                .font(.title3)
                                .foregroundColor(.green.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Capsule())
                        } else {
                            Text("...No Plants Found...")
                                .font(.title3)
                                .foregroundColor(.green.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.top)

                    if let message = deletionMessage {
                        Text(message)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                            .transition(.opacity)
                    }

                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    } else if plants.isEmpty {
                        Text("No plants found.")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(plants) { plant in
                                    NavigationLink(destination: PlantView(plant: plant, namespace: navNamespace)
                                        .navigationTransition(.zoom(sourceID: plant.id, in: navNamespace))) {
                                            PlantCardView(plant: plant, onDelete: {
                                                plantToDelete = plant
                                                showDeleteConfirmation = true
                                            })
                                            .matchedGeometryEffect(id: plant.id, in: navNamespace)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    loadPlants()
                }

                if showDeleteConfirmation, let plant = plantToDelete {
                    Color.black.opacity(0.4).ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("Delete \(plant.name)?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        Text("Are you sure you want to remove this plant from your garden?")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)

                        HStack(spacing: 30) {
                            Button("Cancel") {
                                showDeleteConfirmation = false
                            }
                            .font(.headline)
                            .foregroundColor(.secondary)

                            Button("Delete") {
                                if let plantId = plantToDelete?.id {
                                    APIManager.shared.deletePlant(id: plantId) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success:
                                                deletionMessage = "Plant deleted successfully!"
                                                showDeleteConfirmation = false
                                                plantToDelete = nil
                                                loadPlants()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                    withAnimation {
                                                        deletionMessage = nil
                                                    }
                                                }
                                            case .failure(let error):
                                                errorMessage = "Deletion failed: \(error.localizedDescription)"
                                                showDeleteConfirmation = false
                                            }
                                        }
                                    }
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .transition(.scale)
                }
            }
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            colors: [.zenGreen.opacity(0.8), .zenBeige.opacity(0.6), .green.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    func loadPlants() {
        isLoading = true
        APIManager.shared.fetchPlants { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetched):
                    self.plants = fetched
                case .failure(let error):
                    self.errorMessage = "Failed to load plants."
                    print("Error: \(error)")
                }
            }
        }
    }
}


struct PlantCardView: View {
    let plant: Plant
    var image: UIImage? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                // Image or placeholder
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 180)
                            .cornerRadius(12)

                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green.opacity(0.6))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.green)

                    Text("Species: \(plant.species)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding()

            // 🔒 Overlay Buttons - fixed in top right
            HStack(spacing: 8) {
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.green)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Circle())
                    }
                }

                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(10)
        }
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
    }
}

  
#Preview {
    ViewPlantsView()
}
