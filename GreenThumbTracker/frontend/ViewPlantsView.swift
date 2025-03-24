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

      var body: some View {
          NavigationStack {
              ZStack {
                  gradientBackground

                  VStack(spacing: 16) {
                      Text("My Plants")
                          .font(.largeTitle)
                          .foregroundStyle(.green)
                          .padding(.top)

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
                                      NavigationLink(destination:PlantView(plant: plant, namespace: navNamespace)
                                        .navigationTransition(.zoom(sourceID: plant.id, in:navNamespace))
                                      ) {
                                          PlantCardView(plant: plant)
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
      var image: UIImage? = nil  // Optional image
      var onEdit: (() -> Void)? = nil  // Optional edit action

      var body: some View {
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

              if let onEdit = onEdit {
                  HStack {
                      Spacer()
                      Button {
                          onEdit()
                      } label: {
                          Label("Edit", systemImage: "pencil")
                              .font(.caption)
                              .padding(.horizontal, 12)
                              .padding(.vertical, 6)
                              .background(Color.green.opacity(0.15))
                              .cornerRadius(8)
                      }
                  }
              }
          }
          .padding()
          .background(Color.white.opacity(0.95))
          .cornerRadius(16)
          .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
          .padding(.horizontal, 4) // slightly expand card width visually
      }
  }
#Preview {
    ViewPlantsView()
}
