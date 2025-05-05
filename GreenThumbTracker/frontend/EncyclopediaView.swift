//
//  EncyclopediaView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/3/25.
//

import SwiftUI
import Kingfisher
struct EncyclopediaView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
        
        @State private var query: String = ""
        @State private var allPlants: [TreflePlant] = []
        @State private var filteredPlants: [TreflePlant] = []
    @State private var currentLazyPage = 1
    @State private var isPaginating = false
    @State private var hasMorePages = true
    @State private var page = 1
    @State private var allLoaded = false
    @State private var isFetchingNextPage = false


        @State private var isLoading = false
        @State private var currentPage = 0
        @State private var totalPages = 1
        @State private var totalPlants = 1
        @State private var loadedCount = 0
        @State private var estimatedTimeRemaining: TimeInterval? = nil
        @State private var downloadStartTime: Date? = nil
        @State private var userCancelledDownload = false
        @State private var downloadError: Error? = nil
        @State private var downloadInProgress = false
        @State private var showCancelPrompt = false
        @State private var showRedownloadPrompt = false
        @State private var showSignalLostPrompt = false
    @State private var showClearCacheModal = false
    let useCachedData: Bool

        var progressFileName = "plant_progress.json"

        private func formatTime(_ interval: TimeInterval) -> String {
            if interval >= 3600 {
                let hours = Int(interval) / 3600
                let minutes = (Int(interval) % 3600) / 60
                return "\(hours)h \(minutes)m"
            } else {
                let minutes = Int(interval) / 60
                return "\(minutes)m"
            }
        }
        var body: some View {
            ZStack {
                LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2), .green.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Search for a plant...", text: $query)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onChange(of: query) { _ in filterPlants() }

                    // Download state
                    if downloadInProgress {
                        VStack(spacing: 10) {
                            ProgressView(value: Double(loadedCount), total: Double(totalPlants))
                                .tint(.green)
                            Text("Loading plants... (\(loadedCount)/\(totalPlants))")
                                .font(.subheadline)
                            if let estimate = estimatedTimeRemaining {
                                Text("Estimated time left: \(formatTime(estimate))")
                                    .font(.caption)
                            }

                            Button("Cancel") {
                                showCancelPrompt = true
                            }
                            .foregroundColor(.red)
                            .padding(.top)
                        }
                        .padding()
                    } else if FileManager.default.fileExists(atPath: TreflePersistentCacheManager.shared.cacheURL(for: progressFileName).path) {
                        // Show "Continue" if partial download exists
                        Button(action: {
                            startDownloadAllPlants(resuming: true)
                        }) {
                            VStack {
                                Label("Continue Download", systemImage: "arrow.down.circle")
                                    .font(.headline)
                                if let saved = TreflePersistentCacheManager.shared.load(PlantDownloadProgress.self, from: progressFileName),
                                   let elapsed = saved.elapsedTimeSoFar {
                                    Text("Est. time left: \(formatTime((Double(saved.totalPlants - saved.partialPlants.count) * (elapsed / Double(saved.partialPlants.count)))))")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            if let cached = TreflePersistentCacheManager.shared.load([TreflePlant].self, from: "plants.json"), !cached.isEmpty {
                                showRedownloadPrompt = true
                            } else {
                                startDownloadAllPlants()
                            }
                        }) {
                            Label("Download All Plants", systemImage: "arrow.down.circle")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }

                    if isLoading {
                        VStack {
                            ProgressView(value: Double(loadedCount), total: Double(totalPlants))
                                .tint(.green)
                            Text("Loading plants...  (\(loadedCount)/\(totalPlants))")
                                .foregroundColor(.black)
                                .font(.subheadline)
                                .bold()
                        }
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
                                        .onAppear {
                                            if !useCachedData {
                                                loadNextPageIfNeeded(currentPlant: plant)
                                            }
                                        }

                                    }

                                }
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
                .navigationTitle("Plant Encyclopedia")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                showClearCacheModal = true
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                }

                .onAppear {
                    if useCachedData {
                        if let cached = TreflePersistentCacheManager.shared.load([TreflePlant].self, from: "plants.json") {
                            allPlants = cached
                            filteredPlants = cached
                            print("📦 Loaded \(cached.count) plants from cache.")
                        } else if let progress = TreflePersistentCacheManager.shared.load(PlantDownloadProgress.self, from: progressFileName),
                                  !progress.partialPlants.isEmpty {
                            allPlants = progress.partialPlants
                            filteredPlants = progress.partialPlants
                            print("📦 Loaded \(progress.partialPlants.count) plants from partial progress.")
                        } else {
                            print("⚠️ No cached plant data or partial progress found.")
                        }
                    } else {
                        // fallback behavior for lazy scrolling (unchanged)
                        loadInitialPlants()
                    }
                }

                // Cancel download confirmation
                if showCancelPrompt {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("Cancel download?")
                            .font(.headline)
                        Text("Your progress is saved and you can continue later.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            Button("Keep Going") {
                                showCancelPrompt = false
                            }
                            .padding()
                            .background(Color.zenBeige)
                            .cornerRadius(12)

                            Button("Cancel Download") {
                                userCancelledDownload = true
                                downloadInProgress = false
                                isLoading = false
                                showCancelPrompt = false
                            }
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .padding(40)
                    .transition(.scale)
                }

                // Redownload confirmation
                if showRedownloadPrompt {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("All plants already downloaded.")
                            .font(.headline)
                        Text("Do you want to redownload them all?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("This will clear your local cache.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        HStack {
                            Button("Cancel") {
                                showRedownloadPrompt = false
                            }
                            .padding()
                            .background(Color.zenBeige)
                            .cornerRadius(12)

                            Button("Redownload") {
                                TreflePersistentCacheManager.shared.clear(filename: "plants.json")
                                TreflePersistentCacheManager.shared.clear(filename: progressFileName)
                                showRedownloadPrompt = false
                                startDownloadAllPlants()
                            }
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .padding(40)
                    .transition(.scale)
                }

                // Signal lost during download
                if showSignalLostPrompt {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("Connection lost")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Your download progress was saved. You can resume once you're reconnected.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        HStack {
                            Button("Retry") {
                                showSignalLostPrompt = false
                                startDownloadAllPlants(resuming: true)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)

                            Button("OK") {
                                showSignalLostPrompt = false
                            }
                            .padding()
                            .background(Color.zenBeige)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .padding(40)
                    .transition(.scale)
                }
                if showClearCacheModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .zIndex(1)

                    VStack(spacing: 16) {
                        Text("Clear Plant Cache?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        Text("This will delete all downloaded plants and progress. You'll need to redownload them.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        HStack(spacing: 20) {
                            Button("Cancel") {
                                withAnimation {
                                    showClearCacheModal = false
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.zenBeige)
                            .cornerRadius(12)

                            Button("Clear Cache") {
                                TreflePersistentCacheManager.shared.clear(filename: "plants.json")
                                TreflePersistentCacheManager.shared.clear(filename: "plant_progress.json")
                                allPlants = []
                                filteredPlants = []
                                downloadInProgress = false
                                withAnimation {
                                    showClearCacheModal = false
                                }
                                print("🧹 Cleared plant cache and progress.")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .padding(40)
                    .shadow(radius: 10)
                    .transition(.scale)
                    .zIndex(2)
                }

            }//end outer zstack
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

        private func startDownloadAllPlants(resuming: Bool = false) {
            guard networkMonitor.isConnected else {
                showSignalLostPrompt = true
                return
            }

            isLoading = true
            downloadInProgress = true
            userCancelledDownload = false
            downloadError = nil
            downloadStartTime = Date()
            loadedCount = 0
            estimatedTimeRemaining = nil

            allPlants = []
            filteredPlants = []

            TrefleAPI.shared.preloadAllPlants(
                delay: 0.4,
                startingAt: 1,
                shouldCancel: { self.userCancelledDownload || !networkMonitor.isConnected },
                progress: { loaded, total, page, totalPages, elapsed in
                    DispatchQueue.main.async {
                        self.loadedCount = loaded
                        self.totalPlants = total
                        if loaded > 0 {
                            let avg = elapsed / Double(loaded)
                            self.estimatedTimeRemaining = avg * Double(total - loaded)
                        }
                    }
                },
                completion: { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.downloadInProgress = false
                        self.estimatedTimeRemaining = nil

                        switch result {
                        case .success(let plants):
                            self.allPlants = plants
                            self.filteredPlants = plants
                            TreflePersistentCacheManager.shared.clear(filename: progressFileName)
                            print("✅ Finished downloading \(plants.count) plants")
                        case .failure(let error):
                            if !self.userCancelledDownload {
                                self.downloadError = error
                                if !self.networkMonitor.isConnected {
                                    self.showSignalLostPrompt = true
                                }
                            }
                        }
                    }
                }
            )
        }
    private func loadInitialPlants() {
        isLoading = true
        page = 1
        allPlants = []
        filteredPlants = []
        
        TrefleAPI.shared.getAllPlants(page: page) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let plants):
                    allPlants = plants
                    filteredPlants = plants
                    print("📥 Loaded page 1 with \(plants.count) plants.")
                case .failure(let error):
                    downloadError = error
                    print("❌ Failed to load initial plants: \(error.localizedDescription)")
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
                            print("✅ All pages loaded.")
                        } else {
                            page += 1
                            allPlants.append(contentsOf: newPlants)
                            filterPlants() // Re-apply query if needed
                            print("📥 Appended page \(page) with \(newPlants.count) plants.")
                        }
                    case .failure(let error):
                        downloadError = error
                        print("❌ Failed to load next page: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    }
#Preview {
    EncyclopediaView(useCachedData: false)
}
