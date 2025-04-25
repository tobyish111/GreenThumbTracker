//
//  EncyclopediaView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import SwiftUI
import Kingfisher
struct EncyclopediaView: View {
    @State private var query: String = ""
        @State private var allPlants: [TreflePlant] = []
        @State private var filteredPlants: [TreflePlant] = []

        @State private var isPreloading = false
        @State private var preloadToggle = false

        @State private var isLoading = false
        @State private var currentPage = 0
        @State private var totalPages = 1
        @State private var totalPlants = 1

        @State private var isFetchingNextPage = false
        @State private var page = 1
        @State private var allLoaded = false
        @State private var errorMessage: String?

        var body: some View {
            ZStack {
                LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Toggle("Preload all", isOn: $preloadToggle)
                        .padding()
                        .onChange(of: preloadToggle) { newValue in
                            if newValue {
                                preloadAllPlants()
                            } else {
                                resetLazyLoading()
                            }
                        }

                    TextField("Search for a plant...", text: $query)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    if isLoading {
                        VStack {
                            ProgressView(value: Double(allPlants.count), total: Double(totalPlants))
                                .tint(.green)
                            Text("Loading plants...  (\(allPlants.count)/\(totalPlants))")
                                .foregroundColor(.black)
                                .font(.subheadline)
                                .bold()
                        }
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
                                            KFImage(URL(string: plant.image_url ?? ""))
                                                .placeholder { ProgressView() }
                                                .retry(maxCount: 2, interval: .seconds(2))
                                                .resizable()
                                                .scaledToFill()
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
                                        if !preloadToggle {
                                            loadNextPageIfNeeded(currentPlant: plant)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Plant Encyclopedia")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if preloadToggle {
                        preloadAllPlants()
                    } else {
                        loadInitialPlants()
                    }
                }
                .onChange(of: query) {
                    filterPlants()
                }
            }
        }

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

        private func preloadAllPlants() {
            isLoading = true
            isPreloading = true
            allPlants = []
            filteredPlants = []
            TrefleAPI.shared.preloadAllPlants(
                delay: 0.4,
                progress: { loadedCount, totalCount, pageNum, totalPageCount in
                    DispatchQueue.main.async {
                        self.allPlants = TreflePlantCache.shared.allPlants
                                self.filteredPlants = self.allPlants
                                self.currentPage = pageNum
                                self.totalPages = totalPageCount
                                self.totalPlants = totalCount
                    }
                },
                completion: { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let plants):
                            allPlants = plants
                            filteredPlants = plants
                            print("✅ Preloaded \(plants.count) plants.")
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            )
        }

        private func loadInitialPlants() {
            isLoading = true
            page = 1
            allPlants = []
            TrefleAPI.shared.getAllPlants(page: page) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let plants):
                        allPlants = plants
                        filteredPlants = plants
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }

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
                            }
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }

        private func resetLazyLoading() {
            page = 1
            allLoaded = false
            isPreloading = false
            loadInitialPlants()
        }
    }
#Preview {
    EncyclopediaView()
}
