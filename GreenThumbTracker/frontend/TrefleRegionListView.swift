//
//  TrefleRegionListView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import SwiftUI

struct TrefleRegionListView: View {
    @State private var allRegions: [TrefleDistributionRegion] = []
       @State private var filteredRegions: [TrefleDistributionRegion] = []
       @State private var isLoading = true
       @State private var currentPage = 0
       @State private var totalPages = 1
       @State private var totalRegions = 1
       @State private var errorMessage: String?
       @State private var searchQuery = ""
    @State private var loadedCount = 0
    let useCachedData: Bool

       var body: some View {
           NavigationView {
               ZStack {
                   LinearGradient(colors: [.zenGreen.opacity(0.9), .zenBeige.opacity(0.2)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
                       .ignoresSafeArea()

                   VStack(spacing: 16) {
                       // Search bar
                       TextField("Search regions...", text: $searchQuery)
                           .padding(10)
                           .background(Color.white)
                           .cornerRadius(10)
                           .padding(.horizontal)
                           .onChange(of: searchQuery, perform: { _ in
                               filterRegions()
                           })

                       // Loading state
                       if isLoading {
                           VStack(spacing: 12) {
                               ProgressView(value: Double(currentPage), total: Double(max(totalPages, 1)))
                                   .tint(.green)
                                   .progressViewStyle(LinearProgressViewStyle())
                                   .padding(.horizontal)

                               Text("Loading regions... (\(loadedCount)/\(totalRegions))")
                                   .foregroundColor(.black)
                                   .font(.subheadline)
                                   .bold()
                           }
                           .padding(.top, 60)
                       }

                       // Error state
                       else if let errorMessage = errorMessage {
                           Text("❌ \(errorMessage)")
                               .foregroundColor(.red)
                               .padding()
                       }

                       // Content list
                       else {
                           ScrollView {
                               LazyVStack(spacing: 12) {
                                   ForEach(filteredRegions) { region in
                                       NavigationLink(destination: RegionDetailView(slug: region.slug)) {
                                           TrefleRegionCardView(region: region)
                                       }
                                   }
                               }
                               .padding(.horizontal)
                           }
                       }
                   }
               }
               .navigationTitle("Plant Regions")
               .onAppear {
                   if useCachedData {
                       if let cached = TreflePersistentCacheManager.shared.load([TrefleDistributionRegion].self, from: "regions.json") {
                           print("📦 Loaded regions from cache.")
                           TrefleRegionCache.shared.allRegions = cached
                           TrefleRegionCache.shared.isLoaded = true
                           allRegions = cached
                           filteredRegions = cached
                           isLoading = false
                       } else {
                           print("⚠️ No cached region data found.")
                           isLoading = false
                       }
                   } else if TrefleRegionCache.shared.isLoaded {
                       print("📦 Using in-memory region cache")
                       allRegions = TrefleRegionCache.shared.allRegions
                       filteredRegions = allRegions
                       isLoading = false
                   } else {
                       print("🌍 Fetching regions from Trefle API...")
                       TrefleAPI.shared.preloadAllDistributionRegions(
                           delay: 0.4,
                           progress: { loadedCount, totalCount, currentPage, totalPages in
                               DispatchQueue.main.async {
                                   self.loadedCount = loadedCount
                                   self.totalRegions = totalCount
                                   self.currentPage = currentPage
                                   self.totalPages = totalPages
                                   
                                   //show partial content
                                   self.filteredRegions = Array(TrefleRegionCache.shared.allRegions.prefix(loadedCount))
                               }
                           },
                           completion: { result in
                               DispatchQueue.main.async {
                                   switch result {
                                   case .success(let regions):
                                       TrefleRegionCache.shared.allRegions = regions
                                       TrefleRegionCache.shared.isLoaded = true
                                       TreflePersistentCacheManager.shared.save(regions, to: "regions.json")
                                       allRegions = regions
                                       filteredRegions = regions
                                       isLoading = false
                                       print("✅ Loaded and cached \(regions.count) regions.")
                                   case .failure(let error):
                                       errorMessage = error.localizedDescription
                                       isLoading = false
                                   }
                               }
                           }
                       )
                   }
               }


           }
       }

       private func loadAllRegions() {
           isLoading = true
           allRegions = []
           filteredRegions = []

           TrefleAPI.shared.preloadAllDistributionRegions(
               delay: 0.3,
               progress: { loadedCount, totalCount, page, totalPages in
                   DispatchQueue.main.async {
                       self.currentPage = page
                       self.totalPages = totalPages
                       self.totalRegions = totalCount
                       // Trigger intermediate loading UI update
                       self.filteredRegions = Array(repeating: TrefleDistributionRegion(
                           id: 0, name: "", slug: "", tdwg_code: "", tdwg_level: 0,
                           species_count: 0, links: TrefleDistributionLinks(selfLink: "", plants: "", species: ""),
                           parent: nil, children: []
                       ), count: loadedCount)
                   }
               },
               completion: { result in
                   DispatchQueue.main.async {
                       isLoading = false
                       switch result {
                       case .success(let fetchedRegions):
                           allRegions = fetchedRegions
                           filteredRegions = fetchedRegions
                           TrefleRegionCache.shared.allRegions = fetchedRegions
                           TrefleRegionCache.shared.isLoaded = true
                       case .failure(let error):
                           errorMessage = error.localizedDescription
                       }
                   }
               }
           )
       }

       private func filterRegions() {
           let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
           if trimmed.isEmpty {
               filteredRegions = allRegions
           } else {
               filteredRegions = allRegions.filter {
                   $0.name.localizedCaseInsensitiveContains(trimmed) ||
                   $0.tdwg_code.localizedCaseInsensitiveContains(trimmed)
               }
           }
       }
   }
/*
#Preview {
    TrefleRegionListView()
}
*/
