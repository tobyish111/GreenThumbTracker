//
//  EncyclopediaView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import SwiftUI

struct EncyclopediaView: View {
    @State private var query: String = ""
       @State private var allPlants: [TreflePlant] = []
       @State private var filteredPlants: [TreflePlant] = []
       @State private var isLoading = false
    @State private var isFetchingNextPage = false
        @State private var page = 1
        @State private var allLoaded = false
       @State private var errorMessage: String?


       var body: some View {
           ZStack {
               LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
               .ignoresSafeArea()

               VStack(spacing: 16) {
                   TextField("Search for a plant...", text: $query)
                       .padding()
                       .background(Color.white)
                       .cornerRadius(12)
                       .padding(.horizontal)

                   if isLoading {
                       ProgressView("Loading...")
                           .padding()
                   } else if let message = errorMessage {
                       Text(message)
                           .foregroundColor(.red)
                           .padding()
                   } else {
                       ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredPlants) { plant in
                                        NavigationLink(destination: TreflePlantView(plant: plant)) {
                                                          HStack(spacing: 12) {
                                                              AsyncImage(url: URL(string: plant.image_url ?? "")) { phase in
                                                                  switch phase {
                                                                  case .empty: ProgressView()
                                                                  case .success(let image): image.resizable().scaledToFill()
                                                                  default: Image(systemName: "leaf")
                                                                  }
                                                              }
                                                              .frame(width: 60, height: 60)
                                                              .cornerRadius(8)
                                                              .clipped()

                                                              VStack(alignment: .leading) {
                                                                  Text(plant.common_name ?? "Unknown")
                                                                      .font(.headline)
                                                                      .foregroundColor(.black)
                                                                  Text(plant.scientific_name)
                                                                      .font(.subheadline)
                                                                      .foregroundColor(.gray)
                                                              }
                                                              Spacer()
                                                          }
                                                          .padding()
                                                          .background(Color.white.opacity(0.95))
                                                          .cornerRadius(12)
                                                          .shadow(radius: 3)
                                                      }
                                                      .onAppear {
                                                          loadNextPageIfNeeded(currentPlant: plant)
                                                      }
                                                  }
                                              }
                                              .padding(.horizontal)
                                          }
                                      }
                                  }
               .navigationTitle("Plant Encyclopedia")
               .navigationBarTitleDisplayMode(.inline)
               .onAppear(perform: loadInitialPlants)
               .onChange(of: query) {
                   if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                       filteredPlants = allPlants
                   } else {
                       filteredPlants = allPlants.filter {
                           ($0.common_name ?? "").localizedCaseInsensitiveContains(query) ||
                           $0.scientific_name.localizedCaseInsensitiveContains(query)
                       }
                   }
               }

           }
       }
    //filtering plants in search bar
    private func filterPlants() {
           let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
           if trimmed.isEmpty {
               filteredPlants = allPlants
           } else {
               filteredPlants = allPlants.filter {
                   ($0.common_name ?? "").localizedCaseInsensitiveContains(trimmed) ||
                   $0.scientific_name.localizedCaseInsensitiveContains(trimmed)
               }
           }
       }
    //the page param might need to be hardcoded to 1, watch though
       private func loadInitialPlants() {
           isLoading = true
           TrefleAPI.shared.getAllPlants(page: page) { result in
               DispatchQueue.main.async {
                   isLoading = false
                   switch result {
                   case .success(let plants):
                       self.allPlants = plants
                       self.filteredPlants = plants
                       print("Total plants loaded: \(allPlants.count)")

                   case .failure(let err):
                       self.errorMessage = err.localizedDescription
                   }
               }
           }
           

       }//end load initial plants
    //pagination function
    private func loadNextPageIfNeeded(currentPlant: TreflePlant) {
           guard !isFetchingNextPage && !allLoaded else { return }

           let thresholdIndex = filteredPlants.index(filteredPlants.endIndex, offsetBy: -5)
           if filteredPlants.firstIndex(where: { $0.id == currentPlant.id }) == thresholdIndex {
               isFetchingNextPage = true
               TrefleAPI.shared.getAllPlants(page: page + 1) { result in
                   DispatchQueue.main.async {
                       isFetchingNextPage = false
                       switch result {
                       case .success(let newPlants):
                           if newPlants.isEmpty {
                               allLoaded = true
                           } else {
                               page += 1
                               allPlants.append(contentsOf: newPlants)
                               filterPlants()
                               print("Total plants loaded: \(allPlants.count)") // ❌ Prints too early

                           }
                       case .failure(let error):
                           errorMessage = error.localizedDescription
                       }
                   }
               }
           }
       }
   }

#Preview {
    EncyclopediaView()
}
